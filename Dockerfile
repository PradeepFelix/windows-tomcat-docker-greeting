#Download the windows image
FROM mcr.microsoft.com/windows/servercore:10.0.14393.2068

#ensure the rights are intact to install the required tools
RUN powershell -Command Set-ExecutionPolicy AllSigned
RUN powershell -Command et-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#install java
RUN powershell choco install jdk8
#RUN powershell choco install openjdk11

#install Tomcat
RUN powershell choco install tomcat

#Allow tomcat to access its associated folders and files
RUN powershell icacls "C:\\programdata\\tomcat9" /grant everyone:F /T

#copy the context xml file to tomcat path
COPY \build\context.xml C:\programdata\tomcat9\conf
COPY \build\context.xml C:\programdata\tomcat9\webapps\manager\META-INF
COPY \build\context.xml C:\programdata\tomcat9\webapps\host-manager\META-INF

#Rename the root folder of tomcat
RUN powershell REN C:\programdata\tomcat9\webapps\ROOT C:\programdata\tomcat9\webapps\ROOT1

#Replace server xml file that corresponds to the app
COPY \build\server.xml  C:\programdata\tomcat9\conf

#copy the project / application war to tomcat webapps
COPY \build\HelloGreeting.war  C:\programdata\tomcat9\webapps


#Reboot tomcat server
RUN powershell stop-service Tomcat9 
RUN powershell start-service Tomcat9 

#Keep the container active after creation
CMD [ "cmd" ]