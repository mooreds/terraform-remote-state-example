require 'aws-sdk-sqs' 

def handler(event:, context:)
    sqs = Aws::SQS::Client.new(region: 'us-east-2')
    #{ event: JSON.generate(event), context: JSON.generate(context.inspect) }
    sqs_url = ENV['sqs_url']
    message = Time.now.inspect
    send_message_result = sqs.send_message({
      queue_url: sqs_url, 
      message_body: message,
      message_attributes: {
        "Addlinfo" => {
          string_value: "More info",
          data_type: "String"
        }
      }
    })
    send_message_result.message_id
end
