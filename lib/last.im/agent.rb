require "uppercut"
require "yaml"

class LastIM < Uppercut::Agent
  def initialize(cfgdir = nil)
    @cfgdir = cfgdir
    @cfgdir ||= ENV["HOME"]+"/.last.im/"
    Dir.mkdir(@cfgdir) unless File.exist?(@cfgdir)
    begin
      @credentials = YAML::load(File.read(@cfgdir+"/credentials.yml"))
    rescue Errno::ENOENT
      puts "No credentials found. Please create #{@cfgdir}credentials.yml in the following format:\n\n"
      puts "user: <jabber ID>"
      puts "password: <jabber password>"
      exit(1)
    end
    DataMapper.setup(:default, "sqlite3://#{@cfgdir}/users.dat")
    DataMapper.auto_upgrade!
    super(@credentials["user"]+"/main", @credentials["password"], :listen => true)
  end

  def authenticate(conversation, user, password)
    puts "Here"
  end

  def signout(conversation)
    conversation.send "Sorry to see you go. Your last.fm credentials have been deleted."
  end

  on :subscribe do |conversation|
    conversation.send "Welcome to my last.fm bot! I just need a couple pieces of information and we can get started."
    conversation.send "What is your last.fm username?"
    conversation.wait_for do |username|
      debugger
      conversation.send "Thanks! Now, your password?"
      conversation.wait_for { |password| authenticate(conversation, user, password) }
    end
  end

  on :unsubscribe do |conversation|
    conversation.send "Sorry to see you go. Your last.fm credentials have been deleted."
  end
end

