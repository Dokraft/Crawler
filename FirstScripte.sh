#! /bin/bash#

echo -e "Ce script permet de générer une liste des liens internes et externes avec la source, la destination et l'ancre.\n"

read -rp "Saisir l'URL du site: " _site_url

spinner() {
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

echo -e "Nous parcourons le site pour récupérer la liste d'URL. Cela peut prendre du temps, d'autant plus si votre site en comporte beaucoup.\n"
echo -e "Veuillez patienter.\n"

wget --spider --no-check-certificate --force-html -nd --delete-after -r -l 0 "$_site_url" 2>&1 | grep '^--' | awk '{ print $3 }' | grep -v '\.\(css\|js\|png\|gif\|jpg\|ico\|webmanifest\|svg\|pdf\|txt\)$' | grep -v '\/feed\/\|selectpod\.php\|xmlrpc\.php\|matomo-proxy\.php' | sort | uniq >internal-external-links-list.txt &
spinner

_sep="§"

echo "Source${_sep}Destination${_sep}Ancre" >internal-links-list.csv
echo "Source${_sep}Destination${_sep}Ancre" >external-links-list.csv

echo -e "Nous traitons les URLs. Cela peut prendre du temps.\n"
echo -e "Veuillez patienter."

while read -r _url; do
    _url_list_with_anchor="$(curl -s "$_url" | grep -o '<a .*href=.*>.*</a>' | grep -v '\.\(css\|js\|png\|gif\|jpg\|ico\|webmanifest\|svg\|pdf\|txt\)' | sed -e 's/<a/\n<a/g' | perl -pe 's/(.*?)<a .*?href=['"'"'"]([^'"'"'"]{1,})['"'"'"][^>]*?>(?:<[^>]*>){0,}([^<]*)(?:<.*>){0,}<\/a>(.*?)$/\2'"$_sep"'\3/g' | sed -e '/^$/ d')"

    _int_links="$(echo "$_url_list_with_anchor" | grep -E "(${_site_url%/}|^[/#])")"
    while read -r _internal; do
        echo "${_url}${_sep}${_internal}"
    done <<<"${_int_links}" >>internal-links-list.csv &
    spinner

    _ext_links="$(echo "$_url_list_with_anchor" | grep -Ev "(${_site_url%/}|^[/#])")"
    while read -r _external; do
        echo "${_url}${_sep}${_external}"
    done <<<"${_ext_links}" >>external-links-list.csv &
    spinner
done <internal-external-links-list.txt &
spinner

rm internal-external-links-list.txt

echo -e "Les fichiers internal-links-list.csv et external-links-list.csv ont été générés. Le script est terminé."
