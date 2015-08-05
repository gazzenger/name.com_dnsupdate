# $1 hostname

#Variable declarations
#domain name
domain=mydomain.com
#name.com username
apiname=mydomain
#name.com API token
apitoken=LOOOOOOOOOOOOOOOOOONNNNNNNNNNNNNNNNNNGGGGGGGGGGGGGGGPPPPPAAAAAAAAASSSSSWWWWWWWWWWWOOOOOOOOORRRRRRRRRDDDDDDDDD


#check for empty hostame input argument
if [ -z "$1" ]
   then
     exit
fi

oldip="`curl https://api.name.com/api/domain/list -H 'Api-Username: $apiname' -H 'Api-Token: $apitoken' -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://api.name.com/api/dns/list/$domain | sed 's/},{/\n/g' | grep "$1\.$domain" | sed 's/,/\n/g' | grep "content" | awk -F'"' '{print $4}' `" > /dev/null

newip="`curl http://ipecho.net/plain`"

if [ "$oldip" == "0" ]
 then
#no record exists hence gi amd create a new record

#add new dns record with ip
curl https://api.name.com/api/domain/list -H 'Api-Username: $apiname' -H 'Api-Token: $apitoken' \
-H "Content-Type: application/json" -X POST -d '{"hostname":"'$1'","type":"A","content":"'`curl http://ipecho.net/plain`$2'","ttl":"300"}' https://api.name.com/api/dns/create/$domain > /dev/null

echo `date`" Created new DNS Record with IP Address "$newip" for "$1\.$domain

elif [ "$oldip" != "$newip" ]
 then
#ip has changed, id old record, delete it and create new record

#get dns id
old_id=`curl https://api.name.com/api/domain/list -H 'Api-Username: $apiname' -H 'Api-Token: $apitoken' -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://api.name.com/api/dns/list/$domain | sed 's/},{/\n/g' | grep "$1\.$domain" | sed 's/,/\n/g' | grep "record_id" | awk -F'"' '{print $6}'` > /dev/null

#delete old dns
curl https://api.name.com/api/domain/list -H 'Api-Username: $apiname' -H 'Api-Token: $apitoken' \
-H "Content-Type: application/json" -X POST -d '{"record_id":"'$old_id'"}' https://api.name.com/api/dns/delete/$domain > /dev/null

#add new dns record with ip
curl https://api.name.com/api/domain/list -H 'Api-Username: $apiname' -H 'Api-Token: $apitoken' \
-H "Content-Type: application/json" -X POST -d '{"hostname":"'$1'","type":"A","content":"'`curl http://ipecho.net/plain`'","ttl":"300"}' https://api.name.com/api/dns/create/$domain  > /dev/null

echo `date`" Updated DNS Record with a new IP Address from "$oldip" to "$newip" for "$1\.$domain

else

echo `date`" DNS Record is uptodate with IP Address "$newip" for "$1\.$domain

fi 
#end
