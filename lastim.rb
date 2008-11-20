require "yaml"
$: << File.dirname(__FILE__)+"/lib"
require "uppercut"

Thread.abort_on_exception = true

class BasicNotifier < Uppercut::Notifier
  notifier :basic do |n,data|
    n.to 'tyler@codehallow.com'
    n.send 'Hey kid.'
  end
end

class LastIM < Uppercut::Agent
  def initialize(cfgdir = nil)
    @cfgdir = cfgdir
    @cfgdir ||= File.dirname(__FILE__)+"/.lastim/"
    Dir.mkdir(@cfgdir) unless File.exist?(@cfgdir)
    begin
      @credentials = YAML::load(File.read(@cfgdir+"/credentials.yml"))
    rescue Errno::ENOENT
      puts "No credentials found. Please create #{@cfgdir}credentials.yml in the following format:\n\n"
      puts "user: <jabber ID>"
      puts "password: <jabber password>"
      exit(1)
    end
    super(@credentials["user"]+"/main", @credentials["password"], :listen => true)
  end

  def join
    @listen_thread.join
  end

  def signup(conversation)
  end

  def authenticate(conversation, user, password)
    debugger
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

LastIM.new.join
