require 'json'
require 'net/https'
require 'logger'

def send_alert(event, context)
  logger = Logger.new($stdout)

  logger.info("Event recieved: #{event}")

  alarm = parse_alarm(event)

  uri = URI(ENV['SLACK_WEBHOOK_URL'])
  request = Net::HTTP::Post.new(uri)
  request.body = JSON.dump(message_for_alarm(alarm))
  request.content_type = 'application/json'
  response = Net::Http.start(uri.host, uri.port, :use_ssl => true) do |http|
    http.request(request)
  end

  logger.info("Send slack message. Response: #{response.code} #{response.body}")

  # Should raise if not success
  response.value
end

def parse_alarm(event)
  message = JSON.parse(event)['Records'][0]['Sns']['Message']
  {
    name: message['AlarmName'],
    description: message['AlarmDescription'],
    reason: message['NewStateReason'],
    resource_name: (message['Trigger']['Dimensions'].map { |d| d['value']}).join(' - '),
    state: message['NewStateValue'],
    previous_state: message['OldStateValue'],
    time: message['StateChangeTime']
  }
end

def message_for_alarm(alarm)
  case alarm.state
  when 'ALARM'
    alarm_activated_message(alarm)
  when 'OK'
    alarm_resolved_message(alarm)
  when 'INSUFFICIENT_DATA'
    alarm_activated_message(alarm)
  end
end

def alarm_activated_message(alarm)
  {
    blocks: [
      { 
        type: 'section',
        text: {
          type: 'header',
          text: "#{alarming_slack_emoji} #{ENV['ENVIRONMENT']} alarm triggered: #{alarm[:name]}"
        }
      },
      {
        type: 'divider'
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: "Description: #{alarm[:description]}"
        }
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: "Reason: #{alarm[:reason]}"
        }
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: "New State: #{alarm[:state]}, Previously: #{alarm[:previous_state]}, Time: #{alarm[:time]}"
        }
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: "Resource: #{alarm[:resource_name]}"
        }
      }
    ]
  }
end

def alarming_slack_emoji
  case ENV['ENVIRONMENT']
  when 'Production'
    ':bangbang:'
  when 'Staging'
    ':exclamation:'
  when 'Review'
    ':grey_exclamation:'
  end
end

def alarm_resolved_message(alarm)
  {
    blocks: [
      { 
        type: 'section',
        text: {
          type: 'header',
          text: ":green_circle: #{ENV['ENVIRONMENT']} alarm resolved: #{alarm[:name]}"
        }
      },
      {
        type: 'divider'
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: "Reason: #{alarm[:reason]}"
        }
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: "Resolved at: #{alarm[:time]}, current state: #{alarm[:state]}, previous state: #{alarm[:previous_state]}"
        }
      },
    ]
  }
end

def post(message)
  http = Net::HTTP.new('hooks.slack.com', 443)
  http.use_ssl = true
  request = Net::HTTP::Post.new(ENV['SLACK_WEBHOOK_URL'])
  request.body = message
  http.request(request)
end