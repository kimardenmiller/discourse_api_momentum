$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)

def connect_to_instance(instance)
  @admin_client = 'KM_Admin'
  client = ''
  case instance
  when 'live'
    client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
    client.api_key = ENV['REMOTE_DISCOURSE_API']
    # puts 'Live'
  when 'local'
    client = DiscourseApi::Client.new('http://localhost:3000')
    client.api_key = ENV['LOCAL_DISCOURSE_API']
  else
    puts 'Host unknown'
  end
  client.api_username = @admin_client
  client
end

def apply_to_all_users(client)
  starting_page_of_users = 1
  while starting_page_of_users > 0
    # puts 'Top While'
    client.api_username = @admin_client
    # puts "client.api_username: #{client.api_username}\n"
    @users = client.list_users('active', page: starting_page_of_users)
    if @users.empty?
      starting_page_of_users = 0
    else
      # puts "Page .................. #{starting_page_of_users}"
      @users.each do |user|
        if @target_username
          if user['username'] == @target_username
            # @user_count += 1
            apply_function(client, user)
          end
        elsif not @exclude_user_names.include?(user['username']) and user['active'] == true
          # @user_count += 1
          # puts user['username']
          apply_function(client, user)
          sleep(2) # really needs to be 3?
        end
      end
      starting_page_of_users += 1
    end
  end
end