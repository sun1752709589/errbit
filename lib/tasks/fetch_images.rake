namespace :fetch_images do
  desc "every day 9:00 am fetch bing image"
  task :bing do
    Rake::Task[:environment].invoke
    agent = Mechanize.new
    page = agent.get('http://cn.bing.com/')
    url = /http:\/\/s\.cn\.bing\.net.*?\.jpg/.match(page.body)[0]
    if url && url.size > 10
      Mailer.bing(['syf@huantengsmart.com', 'accw@venturepharm.net'], url).deliver_now
      Mailer.bing(['343776794@qq.com'], url).deliver_now
      # Mailer.bing(['syf@huantengsmart.com', 'email4sun@qq.com'], url).deliver_now
    end
  end
  desc "every day 9:00 am fetch 163 news"
  task :wangyi do
    Rake::Task[:environment].invoke
    agent = Mechanize.new
    page = agent.get('http://c.m.163.com/nc/article/headline/T1348647853363/0-20.html')
    news = JSON.parse(page.body)
    news_title_arr = []
    news.first.last.each do |item|
      news_title_arr << [item['title'], item['url']]
    end
    Mailer.wangyi(['syf@huantengsmart.com', 'accw@venturepharm.net'], news_title_arr).deliver_now
  end
end
