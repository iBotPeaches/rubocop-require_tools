# frozen_string_literal: true

module RuboCop
  module RequireTools
    # Contains current state of an inspected file
    class State
      attr_accessor :defined_constants, :const_stack, :const_aliases

      def initialize
        self.defined_constants = []
        self.const_stack = []
        self.const_aliases = {}
      end

      def require(file: nil)
        Kernel.require(file)
      rescue NameError, LoadError => e
        puts "Note: Could not load #{file}:"
        puts e.message
        puts 'Check your dependencies, they could be circular'
      end

      def require_relative(relative_path: nil)
        Kernel.require_relative(relative_path)
      rescue NameError, LoadError => e
        puts "Note: Could not load relative file #{relative_path}:"
        puts e.message
        puts 'Check your dependencies, they could be circular'
      end

      def access_const(const_name: nil, local_only: false)
        name = const_name.to_s.sub(/^:*/, '').sub(/:*$/, '') # Strip leading/trailing ::

        # Check if this constant access matches an alias pattern
        # e.g., if DisplayType is aliased to A::B::C, then DisplayType::X should resolve to A::B::C::X
        resolved_name = resolve_alias(name)

        # If const_stack is ["A", "B", "C"] all of A, A::B, A::B::C are valid lookup combinations
        prefixes = self.const_stack.reduce([]) { |a, c| a << [a.last, c].compact.join('::') }

        # I use const_get here because in testing const_get and const_defined? have yielded different results
        unless local_only
          result = Object.const_get(resolved_name) rescue nil                                                   # Defined elsewhere, top-level
          result ||= self.defined_constants.find { |c| Object.const_get("#{c}::#{resolved_name}") rescue nil }  # Defined elsewhere, nested
        end

        result ||= self.defined_constants.find { |c| resolved_name == c }                                       # Defined in this file, other module/class
        prefixes.each do |prefix|
          result ||= self.defined_constants.find { |c| [resolved_name, "#{prefix}::#{resolved_name}"].include? c } # Defined in this file, other module/class
          result ||= prefix == resolved_name # Defined in this file, in current module/class
        end

        return result
      end

      def define_const(const_name: nil, is_part_of_stack: true)
        new = []
        self.defined_constants.each do |c|
          found = Object.const_get("#{c}::#{const_name}") rescue nil
          new << found.to_s if found
        end
        self.defined_constants.push(*new)
        self.const_stack.push(const_name) if is_part_of_stack
        self.defined_constants.push(const_name.to_s, self.const_stack.join('::'))
        self.defined_constants.uniq!
      end

      def undefine_const(const_name: nil) # rubocop:disable Lint/UnusedMethodArgument
        self.const_stack.pop
      end

      def const_assigned(const_name: nil)
        full_name = (self.const_stack + [const_name]).join('::')
        self.defined_constants << full_name
        self.defined_constants.uniq!
      end

      def const_aliased(const_name: nil, aliased_to: nil)
        full_name = (self.const_stack + [const_name]).join('::')
        full_name = const_name.to_s if full_name.empty?

        # Track the alias relationship
        self.const_aliases[full_name] = aliased_to
        self.defined_constants << full_name
        self.defined_constants.uniq!
      end

      private

      def resolve_alias(name)
        self.const_aliases.each do |alias_name, target_name|
          if name == alias_name
            return target_name
          elsif name.start_with?("#{alias_name}::")
            return name.sub(/^#{Regexp.escape(alias_name)}/, target_name)
          end
        end
        name
      end
    end
  end
end
