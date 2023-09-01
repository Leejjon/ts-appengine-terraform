cd ../app || exit
npm install

dateString=$(date +%s)

cd ../terraform || exit
terraform apply -auto-approve -var="deployment_version=${dateString}"

cd ../scripts || exit

# Point 100% of the traffic to the new version
gcloud app services set-traffic default --splits=$dateString=1 --quiet
