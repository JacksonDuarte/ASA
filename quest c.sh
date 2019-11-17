#!/bin/bash
  
Principal() {
  echo '####################################################'
  echo '######## SISTEMA DE MANIPULAÇÃO DE DOMÍNIOS ########'
  echo '####################################################'
  echo
  echo "1. Adicionar um novo domínio"
  echo "2. Adicionar um sub-domínio"
  echo "3. Remover um domínio"
  echo "4. Remover um sub-domínio"
  echo "5. Listar domínios"
  echo "6. Sair"
  echo
  echo -n "Qual a opção desejada? "
  read opcao
  case $opcao in
    1) Adicionar_Dominio ;;
    2) Adicionar_Subdominio ;;
    3) Remover_Dominio ;;
    4) Remover_Subdominio ;;
    5) Listar_Dominios ;;
    6) exit ;;
    *) echo ' ' ; echo 'Opção desconhecida, saindo do programa' ; exit ;;
  esac
}
 
Adicionar_Dominio() {
  clear
  echo '####################################################'
  echo '# Aqui você vai inserir o PREFIXO do domínio que   #'
  echo '# deseja ADICIONAR. Por exemplo: se seu dominio    #'
  echo '# for "linux.com.br", o PREFIXO é "linux".         #'
  echo '####################################################'
  echo
  echo -n "Então, qual o PREFIXO do domínio que deseja ADICIONAR? "
  read prefixo
  clear
  echo '####################################################'
  echo '# Agora você deve inserir o SUFIXO do domínio que  #'
  echo '# deseja ADICIONAR. Por exemplo: se seu domínio    #'
  echo '# for "linux.com.br", o SUFIXO é "com.br".         #'
  echo '####################################################'
  echo
  echo -n "Então, qual o SUFIXO do domínio que deseja ADICIONAR? "
  read sufixo
  useradd $prefixo -m -d /var/www/$prefixo.$sufixo -k /etc/skel -s /bin/bash
  clear
  echo '####################################################'
  echo '# Muito bem, agora precisamos definir a senha para #'
  echo '# o seu domínio. Primeiro você vai inserir a senha #'
  echo '# e depois confirma-la, ok? Quando digitar, nada   #'
  echo '# vai aparecer na tela. Não se preocupe. É normal. #'
  echo '####################################################'
  echo
  passwd $prefixo
Quotas() {
  clear
  echo '####################################################'
  echo '# Aqui você vai definir a QUOTA para o domínio     #'
  echo '# QUOTA é o espaço total que o domínio vai poder   #'
  echo '# ocupar no servidor.                              #'
  echo '####################################################'
  echo
  echo "Quantos GB de espaço o domínio $prefixo.$sufixo vai ter?"
  echo
  echo "Opção 1 = 1GB de espaço em disco"
  echo "Opção 2 = 2GB de espaço em disco"
  echo "Opção 3 = 5GB de espaço em disco"
  echo "Opção 4 = 10GB de espaço em disco"
  echo
  echo -n "Qual a opção desejada? "
  read quota
  case $quota in
       1) 1GB ;;
       2) 2GB ;;
       3) 5GB ;;
       4) 10GB ;;
       *) echo ; echo 'Opção desconhecida, tente novamente' ; sleep 3 ; Quotas ;;
  esac
}
1GB() {
  setquota -u $prefixo 1048576 1048576 0 0 -a
}
2GB() {
  setquota -u $prefixo 2097152 2097152 0 0 -a
}
5GB() {
  setquota -u $prefixo 5242880 5242880 0 0 -a
}
10GB() {
  setquota -u $prefixo 10485760 10485760 0 0 -a
}
Quotas
  mkdir /var/log/apache2/$prefixo.$sufixo
  chmod -R 775 /var/www/$prefixo.$sufixo
  chown -R www-data:$prefixo /var/www/$prefixo.$sufixo
  mkdir /etc/apache2/sites-available/$prefixo.$sufixo
  ln -s /etc/apache2/sites-available/$prefixo.$sufixo /etc/apache2/sites-enabled/
  mkdir /var/www/$prefixo.$sufixo/www
  chmod -R 775 /var/www/$prefixo.$sufixo/www
  chown -R www-data:$prefixo /var/www/$prefixo.$sufixo/www
 
  echo "<VirtualHost *:80>" > /etc/apache2/sites-available/$prefixo.$sufixo/www.conf
  echo "ServerName www.$prefixo.$sufixo" >> /etc/apache2/sites-available/$prefixo.$sufixo/www.conf
  echo "DocumentRoot /var/www/$prefixo.$sufixo/www" >> /etc/apache2/sites-available/$prefixo.$sufixo/www.conf
  echo "ErrorLog /var/log/apache2/$prefixo.$sufixo/www-error.log" >> /etc/apache2/sites-available/$prefixo.$sufixo/www.conf
  echo "CustomLog /var/log/apache2/$prefixo.$sufixo/www-access.log combined" >> /etc/apache2/sites-available/$prefixo.$sufixo/www.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-available/$prefixo.$sufixo/www.conf 
 
  mkdir /var/www/$prefixo.$sufixo/redirecionamento
 
  echo "<html><head><script language="JavaScript">document.location.href='https://www.$prefixo.$sufixo/'</script></head>" > /var/www/$prefixo.$sufixo/redirecionamento/index.html
 
  chmod -R 775 /var/www/$prefixo.$sufixo/redirecionamento
  chown -R www-data:$prefixo /var/www/$prefixo.$sufixo/redirecionamento
 
  echo "<VirtualHost *:80>" > /etc/apache2/sites-available/$prefixo.$sufixo/redirecionamento.conf
  echo "ServerName $prefixo.$sufixo" >> /etc/apache2/sites-available/$prefixo.$sufixo/redirecionamento.conf
  echo "DocumentRoot /var/www/$prefixo.$sufixo/redirecionamento" >> /etc/apache2/sites-available/$prefixo.$sufixo/redirecionamento.conf
  echo "ErrorLog /var/log/apache2/$prefixo.$sufixo/redirecionamento-error.log" >> /etc/apache2/sites-available/$prefixo.$sufixo/redirecionamento.conf
  echo "CustomLog /var/log/apache2/$prefixo.$sufixo/redirecionamento-access.log combined" >> /etc/apache2/sites-available/$prefixo.$sufixo/redirecionamento.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-available/$prefixo.$sufixo/redirecionamento.conf
 
  /etc/init.d/apache2 restart 2>&1 > /dev/null 2>&1
  clear
  echo "Domínio $prefixo.$sufixo adicionado com sucesso"
  sleep 3
  clear
  Principal
}
 
Adicionar_Subdominio() {
  clear
  echo '####################################################'
  echo '# Aqui você vai inserir o PREFIXO do domínio no    #'
  echo '# qual deseja ADICIONAR um SUB-DOMÍNIO. Por        #'
  echo '# exemplo: Se seu dominio for "linux.com.br", o    #'
  echo '# PREFIXO é "linux".                               #'
  echo '####################################################'
  echo
  echo -n "Então, qual o PREFIXO do domínio no qual você pretende adicionar o SUB-DOMÍNIO? "
  read prefixo
  clear
  echo '####################################################'
  echo '# Agora você deve inserir o SUFIXO do domínio no   #'
  echo '# qual deseja ADICIONAR um SUB-DOMÍNIO. Por        #'
  echo '# exemplo: se seu domínio "linux.com.br", o SUFIXO #'
  echo '# é "com.br".                                      #'
  echo '####################################################'
  echo
  echo -n "Então, qual o SUFIXO do domínio no qual você pretende adicionar o SUB-DOMÍNIO? "
  read sufixo
  clear
  echo '####################################################'
  echo '# Agora você deve inserir o PREFIXO DO SUBDOMÍNIO. #'
  echo '# Por exemplo, se você deseja criar o sub-domínio  #'  
  echo '# debian.linux.com.br, insira o PREFIXO "debian".  #'
  echo '####################################################'
  echo
  echo -n "Então, qual o PREFIXO do SUB-DOMÍNIO que deseja criar? "
  read subdominio
VERIFICA=$(ls -l /etc/apache2/sites-available/ | grep ^d | cut -b42-80 | grep $prefixo.$sufixo)
if [ "$VERIFICA" = "$prefixo.$sufixo" ]
then
  mkdir /var/www/$prefixo.$sufixo/$subdominio
  chmod -R 775 /var/www/$prefixo.$sufixo/$subdominio
  chown -R www-data:$prefixo /var/www/$prefixo.$sufixo/$subdominio
  echo "<VirtualHost *:80>" > /etc/apache2/sites-available/$prefixo.$sufixo/$subdominio.conf
  echo "ServerName $subdominio.$prefixo.$sufixo" >> /etc/apache2/sites-available/$prefixo.$sufixo/$subdominio.conf
  echo "DocumentRoot /var/www/$prefixo.$sufixo/$subdominio" >> /etc/apache2/sites-available/$prefixo.$sufixo/$subdominio.conf
  echo "ErrorLog /var/log/apache2/$prefixo.$sufixo/$subdominio-error.log" >> /etc/apache2/sites-available/$prefixo.$sufixo/$subdominio.conf
  echo "CustomLog /var/log/apache2/$prefixo.$sufixo/$subdominio-access.log combined" >> /etc/apache2/sites-available/$prefixo.$sufixo/$subdominio.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-available/$prefixo.$sufixo/$subdominio.conf
  /etc/init.d/apache2 restart 2>&1 > /dev/null 2>&1
  clear
  echo "Você criou com sucesso o sub-domínio $subdominio.$prefixo.$sufixo"
  sleep 3
  clear
  Principal
else
  clear
  echo
  echo "Não foi possível criar o sub-domínio desejado porque o domínio $prefixo.$sufixo não existe."
  echo "Tente novamente, dessa vez com mais atenção!"
  sleep 5
  clear
  Principal
fi
}
 
Remover_Dominio() {
  clear
  echo '####################################################'
  echo '# Aqui você vai inserir o PREFIXO do domínio que   #'
  echo '# deseja REMOVER. Por exemplo: se seu dominio for  #'
  echo '# "linux.com.br", o PREFIXO é "linux".             #'
  echo '####################################################'
  echo
  echo -n "Então, qual o PREFIXO do domínio que deseja remover? "
  read prefixo
  clear
  echo '####################################################'
  echo '# Agora você deve inserir o SUFIXO do domínio que  #'
  echo '# deseja REMOVER. Por exemplo: se seu domínio for  #'
  echo '# "linux.com.br", o SUFIXO é "com.br".             #'
  echo '####################################################'
  echo
  echo -n "Então, qual o SUFIXO do domínio que deseja remover? "
  read sufixo
VERIFICA=$(ls -l /etc/apache2/sites-available/ | grep ^d | cut -b42-80 | grep $prefixo.$sufixo)
if [ "$VERIFICA" = "$prefixo.$sufixo" ]
then
   echo
   echo "Tem certeza de remover o domínio (s/n)?"
   read aux1
   aux2 = s
   if [ "$aux1" == "$aux1" ]; then 
    echo "Removendo o domínio $prefixo.$sufixo, por favor aguarde..."
    sleep 3
    setquota -u $prefixo 0 0 0 0 -a
    deluser $prefixo 2>&1 > /dev/null 2>&1
    rm -rf /var/www/$prefixo.$sufixo
    rm -rf /var/log/apache2/$prefixo.$sufixo
    rm -rf /etc/apache2/sites-enabled/$prefixo.$sufixo
    rm -rf /etc/apache2/sites-available/$prefixo.$sufixo
    /etc/init.d/apache2 restart 2>&1 > /dev/null 2>&1
    clear
    echo "Domínio $prefixo.$sufixo removido com sucesso!"
    sleep 3
    clear
    Principal
   else
    Principal
   fi
else
   clear
   echo
   echo "O domínio que você tentou remover foi "$prefixo.$sufixo" e esse domínio não foi encontrado."
   echo "Tente novamente, digitando corretamente o prefixo e o sufixo do domínio."
   sleep 5
   clear
   Principal
fi
}
  
Remover_Subdominio() {
  clear
  echo '####################################################'
  echo '# Aqui você vai inserir o NOME COMPLETO do domínio #'
  echo '# no qual deseja REMOVER um SUB-DOMÍNIO. Por       #'
  echo '# exemplo: "linux.com.br".                         #'
  echo '####################################################'
  echo
  echo -n "Então, qual o NOME COMPLETO do DOMÍNIO no qual deseja remover o SUB-DOMÍNIO? "
  read dominio
  clear
  echo '####################################################'
  echo '# Agora você deve inserir o PREFIXO DO SUBDOMÍNIO  #'
  echo '# que deseja remover. Por exemplo, se você deseja  #'
  echo '# remover o sub-domínio debian.linux.com.br,       #'
  echo '# insira o PREFIXO "debian".                       #'
  echo '####################################################'
  echo
  echo -n "Então, qual o PREFIXO do SUB-DOMÍNIO que deseja remover? "
  read subdominio
VERIFICA=$(ls -l /etc/apache2/sites-available/$dominio/ | grep $subdominio.conf | cut -b41-80)
if [ "$VERIFICA" = "$subdominio.conf" ]
then
   echo
   echo "Tem certeza de remover o domínio (s/n)?"
   read aux1
   aux2 = s
   if [ "$aux1" == "$aux1" ]; then 
    echo "Removendo o sub-domínio $subdominio.$dominio, por favor aguarde..."
    sleep 3
    rm -rf /var/www/$dominio/$subdominio
    rm -rf /etc/apache2/sites-enabled/$dominio/$subdominio.conf
    rm -rf /etc/apache2/sites-available/$dominio/$subdominio.conf
    rm -rf /var/log/apache2/$dominio/$subdominio-*
    /etc/init.d/apache2 restart 2>&1 > /dev/null 2>&1
    clear
    echo "O sub-domínio $subdominio.$dominio foi removido com sucesso!"
    sleep 3
    clear
    Principal
   else
    Principal
   fi
else
   clear
   echo
   echo "O Sub-domínio que você tentou remover foi "$subdominio.$dominio" e esse sub-domínio não foi encontrado."
   echo "Tente novamente, digitando corretamente o domínio completo e o prefixo do sub-domínio."
   sleep 5
   clear
   Principal
fi
}
 
Listar_Dominios(){
  clear
  echo '####################################################'
  echo '# Esse é o resultado do comando abaixo:            #'
  echo '# $ sudo ls /etc/apache2/sites-available/          #'
  echo '# Essa lista contém todos os domínios hospedados   #'
  echo '# nesse servidor.                                  #'
  echo '####################################################'
  echo
  ls -l /etc/apache2/sites-available/ | grep ^d | cut -b41-200
  echo
Voltar(){
  echo -n "Digite "1" para voltar e "2" para sair: "
  read listar
  case $listar in
    1) opcao_1 ;;
    2) opcao_2 ;;
    esac
}
opcao_1() {
clear
Principal
}
opcao_2() {
exit
}
Voltar
}
 
clear
Principal