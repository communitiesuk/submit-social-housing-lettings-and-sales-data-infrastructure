require 'json'
require 'net/https'
require 'logger'

def send_alert(event)
  logger = Logger.new($stdout)

  logger.info("Event recieved: #{event}")

  message = construct_message(event)
  response = send_message(message)

  logger.info("Sent slack message. Response: #{response.code} #{response.body}")

  # Should raise if not success
  response.value
end

def construct_message(event)
  return alarm_message(event) if is_alarm?(event)
  return budget_alert_message(event) if is_budget_alert?(event)
  unknown_alert_message(event)
end

def is_alarm?(event)
  event_message(event).match?('AlarmName')
end

def alarm_message(event)
  alarm = parse_alarm(event)
  message_for_alarm(alarm)
end

def parse_alarm(event)
  message = JSON.parse(event_message(event))
  {
    name: message['AlarmName'],
    description: message['AlarmDescription'],
    reason: message['NewStateReason'],
    state: message['NewStateValue'],
    previous_state: message['OldStateValue'],
    time: message['StateChangeTime']
  }
end

def message_for_alarm(alarm)
  case alarm[:state]
  when 'ALARM'
    alarm_activated_message(alarm)
  when 'OK'
    alarm_resolved_message(alarm)
  when 'INSUFFICIENT_DATA'
    # We set notifications not to be sent to sns when we don't care about these
    alarm_activated_message(alarm)
  else
    raise "Unrecognised alarm state #{alarm[:state]}"
  end
end

def alarm_activated_message(alarm)
  {
    blocks: [
      { 
        type: 'header',
        text: {
          type: 'plain_text',
          text: "#{alarming_slack_emoji} #{ENV['ENVIRONMENT']} alarm triggered: #{alarm[:name]}"
        }
      },
      {
        type: 'divider'
      },
      ({
        type: 'section',
        text: {
          type: 'plain_text',
          text: "#{alarm[:description]}"
        }
      } unless alarm[:description].nil? || alarm[:description].empty?),
      ({
        type: 'section',
        text: {
          type: 'plain_text',
          text: "#{alarm[:reason]}"
        }
      } unless alarm[:reason].nil? || alarm[:reason].empty?),
      {
        type: 'section',
        fields: [
          {
            type: "mrkdwn",
            text: "*New State:*\n#{format_state(alarm[:state])}"
          },
          {
            type: "mrkdwn",
            text: "*Previous State:*\n#{format_state(alarm[:previous_state])}"
          },
          {
            type: "mrkdwn",
            text: "*Changed at:*\n#{alarm[:time]}"
          }
        ]
      },
    ].compact
  }.to_json
end

def alarm_resolved_message(alarm)
  {
    blocks: [
      { 
        type: 'header',
        text: {
          type: 'plain_text',
          text: ":large_green_circle: #{ENV['ENVIRONMENT']} alarm resolved: #{alarm[:name]}"
        }
      },
      {
        type: 'divider'
      },
      ({
        type: 'section',
        text: {
          type: 'plain_text',
          text: " #{alarm[:reason]}"
        }
      } unless alarm[:reason].nil? || alarm[:reason].empty?),
      {
        type: 'section',
        fields: [
          {
            type: 'mrkdwn',
            text: "*New State*\n#{format_state(alarm[:state])}"
          },
          {
            type: 'mrkdwn',
            text: "*Previous State*\n#{format_state(alarm[:previous_state])}"
          },
          {
            type: 'mrkdwn',
            text: "*Resolved at*\n#{alarm[:time]}"
          },
        ]
      },
    ].compact
  }.to_json
end

def format_state(state)
  case state
  when 'ALARM'
    ':red_circle: Alarm'
  when 'OK'
    ':large_green_circle: Ok'
  when 'INSUFFICIENT_DATA'
    ':white_circle: Insufficient Data'
  end
end

def is_budget_alert?(event)
  event_subject(event).start_with?("AWS Budgets:")
end

def budget_alert_message(event)
  {
    blocks: [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: ":moneybag: #{ENV['ENVIRONMENT']} budget alert triggered"
        }
      },
      {
        type: 'divider'
      },
      {
        type: 'section',
        text: {
          type: 'plain_text',
          text: event_message(event)
        }
      }
    ]
  }.to_json
end

def unknown_alert_message(event)
  {
    blocks: [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: "#{alarming_slack_emoji} #{ENV['ENVIRONMENT']} unknown alert type"
        }
      },
      {
        type: 'divider'
      },
      {
        type: 'section',
        text: {
          type: 'plain_text',
          text: event_subject(event)
        }
      },
      {
        type: 'section',
        text: {
          type: 'plain_text',
          text: event_message(event)
        }
      }
    ]
  }.to_json
end

def alarming_slack_emoji
  case ENV['ENVIRONMENT']
  when 'Production'
    ':bangbang:'
  when 'Staging'
    ':exclamation:'
  when 'Review'
    ':grey_exclamation:'
  else
    ':warning: (!unrecognised environment)'
  end
end

def event_subject(event)
  event[:event]['Records'][0]['Sns']['Subject']
end

def event_message(event)
  event[:event]['Records'][0]['Sns']['Message']
end

def send_message(message)
  uri = URI(ENV['SLACK_WEBHOOK_URL'])
  http = Net::HTTP.new(uri.host, 443)
  http.use_ssl = true
  http.post(uri, message, "Content-Type" => "application/json")
end
