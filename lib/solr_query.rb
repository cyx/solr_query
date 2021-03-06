require 'activesupport'

class SolrQuery
  AND = ' AND '
  OR  = ' OR '
  
  def self.escape( str )
    str.to_s.gsub(/([!+\-\(\)\{\}\[\]^\"\~\*\?\:\\])/, '\\\\\1')
  end
  
  def self.create( operator = AND )
    solr_query = new
    yield solr_query
    solr_query.to_s( operator )
  end
  
  attr_reader :conditions
  
  def initialize
    @conditions = []
    @stream     = [ [] ]
  end
  
  def union( &block )
    do_operation( OR, &block )
  end
  
  def intersection( &block )
    do_operation( AND, &block )
  end
  
  def push( condition )
    stream.push( condition )
  end
  
  def stream
    @stream[-1]
  end
  
  def condition( field, value, args = [] )
    return if value.blank?
    escaping = !args.include?( :raw )
    
    if args.include?(:not)
      stream.push("NOT(#{field}:#{quote(escape(value, escaping))})")
    else
      stream.push("#{field}:#{quote(escape(value, escaping))}")
    end
  end
  
  def match( field, value, args = [] )
    return if value.blank?
    escaping = !args.include?( :raw )
    
    if args.include?(:not)
      stream.push("NOT(#{field}:#{like(value, escaping)})")
    else
      stream.push("#{field}:#{like(value, escaping)}")
    end
  end
  
  def term( value, escaping = true )
    return if value.to_s.strip.blank?
    stream.push( quote(escape(value, escaping)) )
  end
  
  def like( value, escaping = true )
    "#{quote(escape(value.downcase, escaping) + '*')}"
  end
  
  def to_s( operator = AND )
    stream.join( operator )
  end
  
  protected
    def parenthesize( str )
      "( #{str} )"
    end
    
    def do_operation( op )
      solr_query = SolrQuery.new
      @stream    << solr_query
      yield
      generated = @stream.pop.to_s( op )
      stream.push(parenthesize(generated)) if generated.present?
    end
    
    def escape( str, escaping = true )
      ret = 
        if escaping
          self.class.escape( str )
        else
          str
        end
      sanitize( ret )
    end
    
    def sanitize( str )
      str.gsub(':', ' ')
    end
    
    def quote( str )
      if str.to_s.index(' ')
        "\"#{str}\""
      else
        str
      end
    end
end
