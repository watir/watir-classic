class Borges::RefreshResponse < Borges::Response

  def initialize(message, location, seconds)
    super()

    @contents = %^<html>
        <head>
        <meta http-equiv="refresh" content="#{seconds};URL=#{location}">
        <title>#{message}</title>
        </head>
        <body>
        <h1>#{message}</h1>
        You are being redirected to <a href="#{location}">#{location}</a>
        </body>
      </html>^
  end

end

