require 'net/http'

class SMS
  def self.notify(to, message)
    http = Net::HTTP.new('www.budgetsms.net', 80);
    m = self.urlencode(message);
    request = Net::HTTP::Post.new('/api/sendsms_utf8/?username=thexa4&userid=9549&handle=d6c7667bf145fe30ce5eb59915503558&from=De%20Bolk&message=' + m);
    response = http.request(request);
    response.body
  end

  def self.urlencode(str)
    str.gsub(/[^a-zA-Z0-9_\.\-]/n) {|s| sprintf('%%%02x', s[0]) }
  end
end
