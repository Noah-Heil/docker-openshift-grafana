# setup Json file config names
for i in {0..5}; do if (($i == 0))  || (($i % 2 == 0)); then curl -s https://grafana.net/api/dashboards?orderBy=name | jq -r --arg bash_i "$i" '"https://grafana.com/api/dashboards/\([..|.id?,.revision?|select(. != null)]|.[$bash_i|tonumber])/revisions/\([..|.id?,.revision?|select(. != null)]|.[(($bash_i|tonumber)+1)])/download"' >> "$PWD/dashboard-manifest.txt"; fi done


# https://grafana.com/api/dashboards/\(.)/revisions/:revision/download


# Download all dashboard json files.
file="$PWD/dashboard-manifest.txt" ; counter=0 ; while IFS= read -r line ; do curl -v "$line" > "$PWD/dashboards/${line}-${counter}.txt" &&  counter=$((counter+1)) ; done < "$file"