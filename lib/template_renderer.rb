class TemplateRenderer
  def initialize(hash, template_loader)
    @hash = hash
    @tl = template_loader
  end
  
  def method_missing(meth, *args, &block)
    if args.length > 0
      return render_template meth.to_s, args[0]
    end
  
    return @hash[meth.to_s] unless @hash[meth.to_s] == nil

    raise "There's no '#{ meth }' here!"
  end
  
  def render(erb)
    ERB.new(erb).result(binding)
  end
  
  def render_template(name, hash, stack = [])
    raise "Circular template dependency!! #{ stack.push(name).join(' -> ') }" if stack.include? name
    
    h2 = {}
    hash.each {|k,v| h2[k.to_s] = v }
    hash.merge! h2
    
    t = @tl.get_template(name)
    TemplateRenderer.new(t['defaults'].merge(hash), @tl).render(t['html'])
  end
end
