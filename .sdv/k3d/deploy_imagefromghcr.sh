jq -c '.[]' ./../../vehicleApp.json | while read i; do
    name=$(jq -r '.Name' <<< "$i")

    pull_url="ghcr.io/$REPO_NAME/$name:$SHA"
    local_tag="localhost:12345/$name:local"

    echo "Remote URL: $pull_url"
    echo "Local URL: $local_tag"

    docker pull $pull_url
    docker tag $pull_url $local_tag
    docker push $local_tag
done

helm install sdv-chart ./../../deploy/helm --values ./values.yml --wait --timeout 60s --debug

sleep 5s
