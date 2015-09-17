
Puppet::Type.newtype(:acl) do
  desc <<-EOT
     Ensures that a set of ACL permissions are applied to a given file
     or directory.

      Example:

          acl { '/var/www/html':
            action      => exact,
            permission  => [
              'user::rwx',
              'group::r-x',
              'mask::rwx',
              'other::r--',
              'default:user::rwx',
              'default:user:www-data:r-x',
              'default:group::r-x',
              'default:mask::rwx',
              'default:other::r--',
            ],
            provider    => posixacl,
            recursive   => true,
          }

      In this example, Puppet will ensure that the user and group
      permissions are set recursively on /var/www/html as well as add
      default permissions that will apply to new directories and files
      created under /var/www/html

      Setting an ACL can change a file's mode bits, so if the file is
      managed by a File resource, that resource needs to set the mode
      bits according to what the calculated mode bits will be, for
      example, the File resource for the ACL above should be:

          file { '/var/www/html':
                 mode => 754,
               }
    EOT

  newparam(:action) do
    desc "What do we do with this list of ACLs? Options are set, unset, exact, and purge"
    newvalues(:set, :unset, :exact, :purge)
    defaultto :set
  end

  newparam(:path) do
    desc "The file or directory to which the ACL applies."
    isnamevar
    validate do |value|
      path = Pathname.new(value)
      unless path.absolute?
        raise ArgumentError, "Path must be absolute: #{path}"
      end
    end
  end

  newparam(:recursemode) do
    desc "Should Puppet apply the ACL recursively with the -R option or
      apply it to individual files?

      lazy means -R option
      deep means apply to every file"

    newvalues(:lazy, :deep)
    defaultto :lazy
  end

  autorequire(:file) do
    if self[:path]
      [self[:path]]
    end
  end

  newproperty(:permission, :array_matching => :all) do
    desc "ACL permission(s)."

    def is_to_s(value)
      if value == :absent or value.include?(:absent)
        super
      else
        value.join(",")
      end
    end

    def should_to_s(value)
      if value == :absent or value.include?(:absent)
        super
      else
        value.join(",")
      end
    end

    def retrieve
      provider.permission
    end

    def strip_perms(pl)
      desc = "Remove permission bits from an ACL line, eg:
              user:root:rwx
                becomes
              user:root:"
      Puppet.debug "permission.strip_perms"
      value = []
      pl.each do |perm|
        if !(perm =~ /^(((u(ser)?)|(g(roup)?)|(m(ask)?)|(o(ther)?)):):/)
          perm = perm.split(':')[0..-2].join(':')
          value << perm
        end
      end
      value.sort
    end

    # in unset_insync and set_insync the test_should has been added as a work around
    #  to prevent puppet-acl from interpreting recursive permission notation (e.g. rwX)
    #  from causing a false mismatch.  A better solution needs to be implemented to
    #  recursively check permissions, not rely upon getfacl
    def unset_insync(cur_perm)
      # Puppet.debug "permission.unset_insync"
      test_should = []
      @should.each { |x| test_should << x.downcase() }
      cp = strip_perms(cur_perm)
      sp = strip_perms(test_should)
      (sp - cp).sort == sp
    end

    def set_insync(cur_perm)
      # Puppet.debug "permission.set_insync"
      test_should = @should.map { |x| x.downcase() }.uniq
      (cur_perm.sort == test_should.sort) or (provider.check_set and ((test_should - cur_perm).length == 0))
    end

    def purge_insync(cur_perm)
      # Puppet.debug "permission.purge_insync"
      cur_perm.each do |perm|
        # If anything other than the mode bits are set, we're not in sync
        if !(perm =~ /^(((u(ser)?)|(g(roup)?)|(o(ther)?)):):/)
          return false
        end
      end
      return true
    end

    def insync?(is)
      cur_perm = provider.permission
      Puppet.debug "permission.insync? cur_perm: #{cur_perm.sort.join(', ')} @should: #{@should.sort.join(', ')}"
      if provider.check_purge
        return purge_insync(cur_perm)
      end
      if provider.check_unset
        return unset_insync(cur_perm)
      end
      return set_insync(cur_perm)
    end

    # Munge into normalised form
    munge do |acl|
      r = ''
      a = acl.split ':', -1 # -1 keeps trailing empty fields.
      if a.length < 3
        raise ArgumentError, "Too few fields.  At least 3 required, got #{a.length}."
      elsif a.length > 4
        raise ArgumentError, "Too many fields.  At most 4 allowed, got #{a.length}."
      end
      if a.length == 4
        d = a.shift
        if d == 'd' || d == 'default'
          r << 'default:'
        else
          raise ArgumentError, %(First field of 4 must be "d" or "default", got "#{d}".)
        end
      end
      t = a.shift # Copy the type.
      r << case t
      when 'u', 'user'
        'user:'
      when 'g', 'group'
        'group:'
      when 'o', 'other'
        'other:'
      when 'm', 'mask'
        'mask:'
      else
        raise ArgumentError, %(Unknown type "#{t}", expected "user", "group", "other" or "mask".)
      end
      r << "#{a.shift}:" # Copy the "who".
      p = a.shift
      if p =~ /[0-7]/
        p = p.oct
        r << ( p | 4 ? 'r':'-')
        r << ( p | 2 ? 'w':'-')
        r << ( p | 1 ? 'x':'-')
      else
        # Not the most efficient but checks for multiple and invalid chars.
        s = p.tr '-', ''
        r << (s.sub!('r', '')?'r':'-')
        r << (s.sub!('w', '')?'w':'-')
        r << (s.sub!('x', '')?'x':'-')#'
        if !s.empty?
          raise ArgumentError, %(Invalid permission set "#{p}".)
        end
      end
      r
    end
  end

  newparam(:recursive) do
    desc "Apply ACLs recursively."
    newvalues(:true, :false)
    defaultto :false
  end

  def newchild(path)
    full_path = ::File.join(self[:path], path)
    options = @original_parameters.merge(:name => full_path).reject { |param, value| value.nil? }
    unless File.directory?(options[:name]) then
      options[:permission].reject! { |acl| acl.split(':', -1).length == 4 } if options.include?(:permission)
    end
    [:recursive, :recursemode, :path].each do |param|
      options.delete(param) if options.include?(param)
    end
    self.class.new(options)
  end

  def generate
    return [] unless self[:recursive] == :true and self[:recursemode] == :deep
    return [] unless File.directory?(self[:path])
    results = []
    Dir.chdir(self[:path]) do
      Dir['**/*'].each do |path|
        results << newchild(path)
      end
    end
    results
  end

  validate do
    unless self[:permission]
      raise(Puppet::Error, "permission is a required property.")
    end
  end

end
