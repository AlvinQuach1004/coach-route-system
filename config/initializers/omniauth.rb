OmniAuth.config.before_request_phase do |env|  
  request = Rack::Request.new(env)  
  request.session['omniauth.state'] = OmniAuth::Utils.generate_state  
end
