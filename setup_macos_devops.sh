#!/bin/bash

brew install python3

python3 get-pip.py
brew postinstall python3
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
/Library/Developer/CommandLineTools/usr/bin/python3 -m pip install --upgrade pip

{
cat <<EOF
# MacPorts Installer addition on 2021-07-27_at_10:44:03: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.
export PATH="$PATH:/Users/admin/Library/Python/3.8/bin:/Users/admin/Library/Python/3.9/bin"
EOF
} > ~/.zprofile

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user

# /**********************************/
#  PIP INSTALL
# /**********************************/

pip install --user ansible

cd /Volumes/uga/app/devops/00-ansible-kubernete-cluster/local/cluster-local-vms
vagrant up --provision

# /*** GIT_UPLOADED ***?
# #!/bin/bash
# #/-- source :  setup_k8s_dashboard.sh
# #---------------------------------------------#
# #-- SETUP KUBERNETES DASHBOARD              --#
# #---------------------------------------------#

# #-- Create the dashboard --#
# YAML='https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml'
# sudo kubectl create -f ${YAML}

# #-- Expose Dashboard to NodePort --#
# sudo kubectl -n kubernetes-dashboard edit service kubernetes-dashboard

# #-- Create the dashboard service account --#
# sudo kubectl create serviceaccount dashboard-admin-sa
# sudo kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa

# kdashboard(){
# #-- Get Dashboard Login Details --#
# DashboardPort=$(
#     sudo kubectl get svc  -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard \
#     | grep 'kubernetes-dashboard' \
#     | awk '{print $5}' \
#     | sed -e 's|\/|:|g' \
#     | awk -F':' '{print $2}' 
#     )

# MasterIp=$(
#     sudo kubectl get nodes -o wide | grep master | awk '{ print $6 }'
#     )

# LoginToken=$(
#     sudo kubectl describe secret \
#         $(sudo kubectl get secrets | awk '{print $1}'| grep dashboard-admin-sa-token) \
#       | grep token \
#       | egrep -v 'Name|Type' \
#       | sed -e "s/  /\\n/" \
#       | grep -v token \
#       | sed 's/^ *//g'
#       )

# cat <<EOF
# /**************************************/
# /** Dashboard Login Details:         **/
# /--------------------------------------/

# https://${MasterIp}:${DashboardPort}

# Token:

# ${LoginToken}

# EOF
# #---------------------------------------------#
# }


install_jenkins_via_yaml(){

# ---
# Easiest install that works.... DON'T USE HELM OR OTHER METHODS !!!
# ---
# https://www.jenkins.io/doc/book/installing/kubernetes/#access-jenkins-dashboard

sudo kubectl create namespace jenkins
cd ~/uga
wget https://raw.githubusercontent.com/jenkins-infra/jenkins.io/master/content/doc/tutorials/kubernetes/installing-jenkins-on-kubernetes/jenkins-deployment.yaml
sudo kubectl create -f jenkins-deployment.yaml -n jenkins
sudo kubectl get deployments -n jenkins

wget https://raw.githubusercontent.com/jenkins-infra/jenkins.io/master/content/doc/tutorials/kubernetes/installing-jenkins-on-kubernetes/jenkins-service.yaml
sudo kubectl create -f jenkins-service.yaml -n jenkins
sudo kubectl get services -n jenkins
sudo kubectl get pods -n jenkins
}

get_jenkins_login(){
MasterIp=$(
    sudo kubectl get nodes -o wide | grep master | awk '{ print $6 }'
    )

NodePort=$(
    sudo kubectl get services --namespace jenkins \
        | grep 'NodePort' \
        | awk '{print $5}' \
        | sed -e 's|\/|:|g' \
        | awk -F':' '{print $2}' 
    )

InitialAdminPassword=$(
    sudo kubectl logs $(sudo kubectl get pods -n jenkins \
        | grep jenkins \
        | awk '{print $1}') -n jenkins \
        | sed -n '/generated/,/initialAdminPassword/p' \
        | egrep -v 'Jenkins|Please|initialAdminPassword' \
        | sed '/^$/d'
    )

cat <<EOF
/**************************************/
/** Jenkins Login Details:           **/
/--------------------------------------/

http://${MasterIp}:${NodePort}

InitialAdminPassword:

${InitialAdminPassword}

EOF

}


# http://192.168.7.2:31090/

setup_jenkins_agent(){

	# sudo apt install default-jre
	# sudo mkdir /var/jenkins
	# sudo chmod  -R 777 /var/jenkins

#-- run this after geerlingguy.jenkins on all non-master nodes
#-- need to & the java exec cmd. or node is black in master console.
		#-- K8s jenkins install: wget http://192.168.7.2:31090/jnlpJars/agent.jar
wget http://192.168.7.2:8080/jnlpJars/agent.jar

#-- Goto Jenkins master and add 2x new nodes (get java command for each one)
java -jar agent.jar -jnlpUrl http://192.168.7.2:8080/computer/kube1/jenkins-agent.jnlp -secret 6f9fdac4aa48b7467d92ec37b87e4ba67b7ead36a705ae0b8e1793d877002b8b -workDir "/var/jenkins" &
java -jar agent.jar -jnlpUrl http://192.168.7.2:8080/computer/kube2/jenkins-agent.jnlp -secret 8899213ef2de0cdd635f856f7cd1bcecf1068d9450098d23ea4b06c46317ca0d 

user: admin
password: admin 
http://192.168.7.2:8080


Install kubernetes plugin
Install Pipeline (workflow-agrregator) [installs Git]
Install pipeline: API
Install Dashboard-view
Install Performance
Install Job and Stage monitoring 
Install Job/Queue/Slaves Monitoring 
Install Slave Monitor for system load average 
Install Slave Monitor for network connectivity 
Install Monitoring Disk-usage Metrics
Install Dark-theme (then: gfoto user -> configure -> themes)

restart Jenkins...  

kube2 agent API link: http://192.168.7.2:42531/

}


export PATH=$PATH:/usr/local/Cellar/dos2unix/7.4.2/bin


kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{.}}{{"\n"}}{{end}}{{end}}{{end}}'

# vagrant@kmaster:~$ sudo kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{.}}{{"\n"}}{{end}}{{end}}{{end}}'
# 31090map[nodePort:31090 port:8080 protocol:TCP targetPort:8080]
# 32554map[nodePort:32554 port:443 protocol:TCP targetPort:8443]


# /**************************************/
# JENKINS GIT INTEGRATION
# # /**************************************/

# Demo: https://www.youtube.com/watch?v=bGqS0f4Utn4&ab_channel=AutomationStepbyStep

echo "# HelloWorld" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/karlring-devops/HelloWorld.git
git push -u origin main


When creating NEW JOB, in the Git config section ensure
"Branch Specifier" == "**"



Failed to load: Kubernetes Credentials Plugin (0.9.0)
 - Plugin is missing: kubernetes-client-api (5.4.1)

 
