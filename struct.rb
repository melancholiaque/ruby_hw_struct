module MyStruct
  def self.new(name, *arg_names, &block)

    if name.is_a? Symbol
      arg_names.unshift name
      name = nil
    end

    klass = Class.new(&block)

    klass.class_eval do

      attr_accessor(*arg_names)

      define_method :initialize do |*args|
        raise ArgumentError unless args.count == arg_names.count
        arg_names.zip args.each do |n, v|
          instance_variable_set("@#{n}", v)
        end
      end

      def ==(other)
        other.class == self.class && other.values == values
      end

      def [](var)
        return values[var] if var.is_a? Integer
        instance_variable_get("@#{var}")
      end

      def []=(var, obj)
        attr = var.is_a?(Integer) && instance_variables[var] ||
               "@#{var}"
        instance_variable_set(attr, obj)
      end

      def dig(*args)
        args.reduce(self) { |o, a| o&.[] a }
      end

      def each(&block)
        values.each(&block)
      end

      def each_pair(&block)
        members.zip(values).each(&block)
      end

      def eql?(other)
        self.class == other.class && members == other.members
      end

      def hash
        to_h.hash
      end

      define_method :inspect do
        iv = members.zip(values).map { |k, v| "#{k.to_s}=#{v.inspect}" }
        "<MyStruct #{name || 'anonymous'} #{iv.join ' '}>"
      end

      def length
        members.length
      end

      define_method :members do
        arg_names
      end

      def select(&block)
        values.select(&block)
      end

      def size
        members.count
      end

      def to_a
        values
      end

      def to_h
        Hash[members.zip(values)]
      end

      def values
        instance_variables.map { |v| instance_variable_get(v) }
      end

      def values_at(*selector)
        selector.map { |k| self[k] }
      end

      def is_a?(type)
        return true if type == MyStruct
        super
      end

      alias_method :to_s, :inspect
    end

    const_set(name, klass) if name

    klass
  end
end
