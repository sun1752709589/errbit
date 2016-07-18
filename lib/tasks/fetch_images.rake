namespace :fetch_images do
  desc "every day 9:00 am fetch bing image"
  task :bing do
    Rake::Task[:environment].invoke
    agent = Mechanize.new
    page = agent.get('http://cn.bing.com/')
    url = /http:\/\/s\.cn\.bing\.net.*?\.jpg/.match(page.body)[0]
    if url && url.size > 10
      Mailer.bing(url).deliver_now
    end
  end
end
