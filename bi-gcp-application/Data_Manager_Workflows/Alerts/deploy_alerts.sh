notification_channels=(
  "vvishnubhatla@ntta.org"
  "stulshibagwale@ntta.org"
  "ggujjula@ntta.org"
  "smetla@ntta.org"
  "rsomana@ntta.org"
  "kshada@ntta.org"
  "sdontireddy@ntta.org"
  "ukumar@ntta.org"
  "sbandi@ntta.org"
  "prasannav@ntta.org"
  "vbailur@ntta.org"
  # Add more email addresses here if needed
)

if [ -z "$1" ]; then
    echo "Warning: project ID not passed as paramater. Please provide project ID as shown below. "
    echo "./deploy_alerts.sh  <PROJECT_ID> "
    exit 1
fi

#Read Project ID as a parameter
project_id="$1"

# Array to store notification channel IDs
notification_channel_ids=()

# Retrieve existing notification channels
existing_channels=$(gcloud alpha monitoring channels list --project="$project_id" --format="value(name,labels.email_address)")
  echo "channel ids $notification_channel_ids"

# Loop through each notification channel
for channel in "${notification_channels[@]}"; do
  echo "Checking if notification channel for $channel already exists..."
  
  # Check if the notification channel already exists
  channel_exists=$(echo "$existing_channels" | grep "$channel")

  if [ -z "$channel_exists" ]; then
    echo "Notification channel for $channel does not exist. Creating..."
    
    # Create notification channel using gcloud command
    channel_id=$(gcloud alpha monitoring channels create \
      --description="test notification" \
      --display-name="$channel" \
      --type=email \
      --channel-labels=email_address="$channel" \
      --project="$project_id" \
      --format="value(name)")
  else
    echo "Notification channel for $channel already exists."
    channel_id=$(echo "$channel_exists" | awk '{print $1}')
  fi
  # Add the notification channel ID to the array
  notification_channel_ids+=("$channel_id")

  # Add the notification channel to the JSON file
  
done
# List to store channel ids
id_list=""
for id in "${notification_channel_ids[@]}"; do
    if [ -z "$id_list" ]; then
        id_list="$id"
    else
        id_list="$id_list,$id"
    fi
  done


# Store all the displayname of the alerts
existing_alerts=$(gcloud alpha monitoring policies list --project="$project_id" --format="value(displayName)")

echo "existing alert display names:"
echo "$existing_alerts"
echo "------------------"

while IFS= read -r line; do
    existing_alerts_list+=("$line")
done <<< "$existing_alerts"



declare -A alerts_to_create

for file in $(ls -R *.json); do
    # Check if the file exists and is a regular file
    if [ -f "$file" ]; then
        # Read the displayName key from the JSON file
        display_name=$(jq -r '.displayName' "$file")
        # Check if displayName is not null
        if [ ! -z "$display_name" ]; then
            # Add displayName and filename to the associative array
            alerts_to_create["$display_name"]=$file
        fi
    fi
done


for display_name in "${!alerts_to_create[@]}"; do
    exists=false
    for alert_displayname in "${existing_alerts_list[@]}"; do
      if [[ "$alert_displayname" == "$display_name" ]]; then
        exists=true
        alertid=$(gcloud alpha monitoring policies list --project="$project_id" --format="value(Name)" --filter "displayName:('$display_name')") 
      fi
    done
    if [ "$exists" = true ]; then
        echo "updating alert with name - $display_name..."
        # Run the query to create alert using the JSON file
        gcloud alpha monitoring policies update $alertid --policy-from-file=${alerts_to_create[$display_name]} --display-name="$display_name" --add-notification-channels="$id_list" --project="$project_id"
    else
        echo "creating alert with name - $display_name..."
        # Run the query to create alert using the JSON file
        gcloud alpha monitoring policies create --notification-channels="$id_list" --policy-from-file=${alerts_to_create[$display_name]} --display-name="$display_name" --project="$project_id"
    fi
done


