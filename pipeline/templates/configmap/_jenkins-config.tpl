{{- define "override_config_map" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-jenkins
  labels:
    app: {{ template "jenkins.fullname" . }}
data:
  config.xml: |-
    <?xml version='1.0' encoding='UTF-8'?>
    <hudson>
      <disabledAdministrativeMonitors/>
      <version>{{ .Values.Master.ImageTag }}</version>
      <numExecutors>0</numExecutors>
      <mode>NORMAL</mode>
      <useSecurity>false</useSecurity>
      <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
        <denyAnonymousReadAccess>false</denyAnonymousReadAccess>
      </authorizationStrategy>
      <disableRememberMe>false</disableRememberMe>
      <projectNamingStrategy class="jenkins.model.ProjectNamingStrategy$DefaultProjectNamingStrategy"/>
      <workspaceDir>${JENKINS_HOME}/workspace/${ITEM_FULLNAME}</workspaceDir>
      <buildsDir>${ITEM_ROOTDIR}/builds</buildsDir>
      <markupFormatter class="hudson.markup.EscapedMarkupFormatter"/>
      <jdks/>
      <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
      <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar"/>
      <clouds>
        <org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud plugin="kubernetes@1.4">
          <name>kubernetes</name>
          <templates>
{{- if .Values.Agent.Enabled }}
            <org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
              <name>jnlp</name>
              <image>{{ .Values.Agent.Image }}:{{ .Values.Agent.ImageTag }}</image>
              <privileged>false</privileged>
              <alwaysPullImage>{{ .Values.Agent.AlwaysPullImage }}</alwaysPullImage>
              <command></command>
              <args></args>
              <remoteFs>/home/jenkins</remoteFs>
              <instanceCap>2147483647</instanceCap>
              <label></label>
              <nodeSelector>
                {{- $local := dict "first" true }}
                {{- range $key, $value := .Values.Agent.NodeSelector }}
                  {{- if not $local.first }},{{- end }}
                  {{- $key }}={{ $value }}
                  {{- $_ := set $local "first" false }}
                {{- end }}</nodeSelector>
              <resourceRequestCpu>{{ .Values.Agent.Cpu }}</resourceRequestCpu>
              <resourceRequestMemory>{{ .Values.Agent.Memory }}</resourceRequestMemory>
              <resourceLimitCpu>{{ .Values.Agent.Cpu }}</resourceLimitCpu>
              <resourceLimitMemory>{{ .Values.Agent.Memory }}</resourceLimitMemory>
              <volumes>
                <org.csanchez.jenkins.plugins.kubernetes.PodVolumes_-HostPathVolume>
                  <mountPath>/usr/bin/docker</mountPath>
                  <hostPath>/usr/bin/docker</hostPath>
                </org.csanchez.jenkins.plugins.kubernetes.PodVolumes_-HostPathVolume>
                <org.csanchez.jenkins.plugins.kubernetes.PodVolumes_-HostPathVolume>
                  <mountPath>/var/run/docker.sock</mountPath>
                  <hostPath>/var/run/docker.sock</hostPath>
                </org.csanchez.jenkins.plugins.kubernetes.PodVolumes_-HostPathVolume>
                <org.csanchez.jenkins.plugins.kubernetes.volumes.PersistentVolumeClaim>
                  <mountPath>/home/jenkins/.m2</mountPath>
                  <claimName>jenkins-maven-repo</claimName>
                  <readOnly>false</readOnly>
                </org.csanchez.jenkins.plugins.kubernetes.volumes.PersistentVolumeClaim>
              </volumes>
              <envVars/>
              <annotations/>
              <imagePullSecrets/>
            </org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
{{- end -}}
          </templates>
          <serverUrl>https://kubernetes.default</serverUrl>
          <skipTlsVerify>false</skipTlsVerify>
          <namespace>{{ .Release.Namespace }}</namespace>
          <jenkinsUrl>http://{{ .Release.Name }}-jenkins:8080</jenkinsUrl>
          <jenkinsTunnel>{{ .Release.Name }}-jenkins-agent:50000</jenkinsTunnel>
          <containerCap>0</containerCap>
          <retentionTimeout>5</retentionTimeout>
        </org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud>
      </clouds>
      <quietPeriod>0</quietPeriod>
      <scmCheckoutRetryCount>0</scmCheckoutRetryCount>
      <views>
        <hudson.model.AllView>
          <owner class="hudson" reference="../../.."/>
          <name>All</name>
          <filterExecutors>false</filterExecutors>
          <filterQueue>false</filterQueue>
          <properties class="hudson.model.View$PropertyList"/>
        </hudson.model.AllView>
      </views>
      <primaryView>All</primaryView>
      <slaveAgentPort>50000</slaveAgentPort>
      <label></label>
      <nodeProperties/>
      <globalNodeProperties/>
      <noUsageStatistics>true</noUsageStatistics>
    </hudson>
  settings.xml: |-
    <?xml version='1.0' encoding='UTF-8'?>
    <settings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xmlns="http://maven.apache.org/SETTINGS/1.0.0"
              xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                          https://maven.apache.org/xsd/settings-1.0.0.xsd">
        <localRepository>/var/jenkins_home/.m2/repository</localRepository>
    </settings>
  apply_config.sh: |-
    mkdir -p /usr/share/jenkins/ref/secrets/;
    echo "false" > /usr/share/jenkins/ref/secrets/slave-to-master-security-kill-switch;
    cp -n /var/jenkins_config/config.xml /var/jenkins_home/;
    mkdir -p /home/jenkins/.m2;
    cp -n /var/jenkins_config/settings.xml /home/jenkins/.m2/;
{{- if .Values.Master.InstallPlugins }}
    cp -n /var/jenkins_config/plugins.txt /var/jenkins_home/;
    /usr/local/bin/install-plugins.sh `echo $(cat /var/jenkins_home/plugins.txt)`;
{{- end }}
{{- if .Values.Master.ScriptApproval }}
    cp -n /var/jenkins_config/scriptapproval.xml /var/jenkins_home/scriptApproval.xml;
{{- end }}
{{- if .Values.Master.InitScripts }}
    mkdir -p /var/jenkins_home/init.groovy.d/;
    cp -n /var/jenkins_config/*.groovy /var/jenkins_home/init.groovy.d/;
{{- end }}
{{- range $key, $val := .Values.Master.InitScripts }}
  init{{ $key }}.groovy: |-
{{ $val | indent 4}}
{{- end }}
  plugins.txt: |-
{{- if .Values.Master.InstallPlugins }}
{{- range $index, $val := .Values.Master.InstallPlugins }}
{{ $val | indent 4 }}
{{- end }}
{{- end }}
{{- end }}
