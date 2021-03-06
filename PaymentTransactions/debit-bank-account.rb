require 'rubygems'
require 'yaml'
require 'authorizenet' 
require 'securerandom'

  include AuthorizeNet::API

  def debit_bank_account()
    config = YAML.load_file(File.dirname(__FILE__) + "/../credentials.yml")
  
    transaction = Transaction.new(config['api_login_id'], config['api_transaction_key'], :gateway => :sandbox)
    
    request = CreateTransactionRequest.new
  
    request.transactionRequest = TransactionRequestType.new()
    request.transactionRequest.amount = ((SecureRandom.random_number + 1 ) * 15 ).round(2)
    request.transactionRequest.payment = PaymentType.new
	#Generate random bank account number
	randomAccountNumber= Random.rand(100000000..9999999999).to_s;
    request.transactionRequest.payment.bankAccount = BankAccountType.new('checking','122000661',"'#{randomAccountNumber}'", 'John Doe','WEB','Wells Fargo Bank NA','101') 
    request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
    request.transactionRequest.order = OrderType.new("invoiceNumber#{(SecureRandom.random_number*1000000).round(0)}","Order Description")    

    response = transaction.create_transaction(request)

    if response != nil
      if response.messages.resultCode == MessageTypeEnum::Ok
        if response.transactionResponse != nil && (response.transactionResponse.messages != nil)
          puts "Successfully debited bank account."
          puts "  Transaction ID: #{response.transactionResponse.transId}"
          puts "  Transaction response code: #{response.transactionResponse.responseCode}"
          puts "  Code: #{response.transactionResponse.messages.messages[0].code}"
		      puts "  Description: #{response.transactionResponse.messages.messages[0].description}"
        else
          puts "Transaction Failed"
          puts "Transaction response code: #{response.transactionResponse.responseCode}"          
          if response.transactionResponse.errors != nil
            puts "  Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
            puts "  Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
          end
          puts "Failed to debit bank account."
        end
      else
        puts "Transaction Failed"
        if response.transactionResponse != nil && response.transactionResponse.errors != nil
          puts "  Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
          puts "  Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
        else
          puts "  Error Code: #{response.messages.messages[0].code}"
          puts "  Error Message: #{response.messages.messages[0].text}"
        end
        puts "Failed to debit bank account."
      end
    else
      puts "Response is null"
      raise "Failed to debit bank account."
    end

    return response
  end
  
if __FILE__ == $0
  debit_bank_account()
end
