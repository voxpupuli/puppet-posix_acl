# frozen_string_literal: true

require 'spec_helper'
acl_type = Puppet::Type.type(:posix_acl)

describe acl_type do
  context 'when not setting parameters' do
    it 'fails without permissions' do
      expect do
        acl_type.new name: '/tmp/foo'
      end.to raise_error(Puppet::ResourceError)
    end
  end

  context 'when setting parameters' do
    it 'works with a correct permission parameter' do
      resource = acl_type.new name: '/tmp/foo', permission: ['user:root:rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['user:root:rwx'])
    end

    it 'works with a correct permission parameter that includes a default' do
      resource = acl_type.new name: '/tmp/foo', permission: ['default:user:root:rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['default:user:root:rwx'])
    end

    it 'works with octal 0 permission parameter' do
      resource = acl_type.new name: '/tmp/foo', permission: ['user:root:0']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['user:root:---'])
    end

    it 'works with octal 7 permission parameter' do
      resource = acl_type.new name: '/tmp/foo', permission: ['user:root:7']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['user:root:rwx'])
    end

    it 'converts a permission string to an array' do
      resource = acl_type.new name: '/tmp/foo', permission: 'user:root:rwx'
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['user:root:rwx'])
    end

    it 'converts the u: shorcut to user:' do
      resource = acl_type.new name: '/tmp/foo', permission: ['u:root:rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['user:root:rwx'])
    end

    it 'converts the g: shorcut to group:' do
      resource = acl_type.new name: '/tmp/foo', permission: ['g:root:rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['group:root:rwx'])
    end

    it 'converts the m: shorcut to mask:' do
      resource = acl_type.new name: '/tmp/foo', permission: ['m::rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['mask::rwx'])
    end

    it 'converts the o: shorcut to other:' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:permission]).to eq(['other::rwx'])
    end

    it 'has the "set" action by default' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:action]).to eq(:set)
    end

    it 'accepts an action "set"' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], action: :set
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:action]).to eq(:set)
    end

    it 'accepts an action "purge"' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], action: :purge
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:action]).to eq(:purge)
    end

    it 'accepts an action "unset"' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], action: :unset
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:action]).to eq(:unset)
    end

    it 'accepts an action "exact"' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], action: :exact
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:action]).to eq(:exact)
    end

    it 'has path as namevar' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:path]).to eq(resource[:name])
    end

    it 'accepts a path parameter' do
      resource = acl_type.new path: '/tmp/foo', permission: ['o::rwx'], action: :exact
      expect(resource[:path]).to eq('/tmp/foo')
      expect(resource[:name]).to eq(resource[:path])
    end

    it 'is not recursive by default' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:recursive]).to eq(:false)
    end

    it 'accepts a recursive "true"' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], recursive: true
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:recursive]).to eq(:true)
    end

    it 'accepts a recurse "false"' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], recursive: false
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:recursive]).to eq(:false)
    end

    it 'gets recursemode lazy by default' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:recursemode]).to eq(:lazy)
    end

    it 'accepts a recursemode deep' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], recursemode: 'deep'
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:recursemode]).to eq(:deep)
    end

    it 'accepts a recursemode lazy' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], recursemode: :lazy
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:recursemode]).to eq(:lazy)
    end

    it 'gets ignore_missing false by default' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx']
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:ignore_missing]).to eq(:false)
    end

    it 'accepts an ignore_missing "quiet"' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], ignore_missing: :quiet
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:ignore_missing]).to eq(:quiet)
    end

    it 'accepts an ignore_missing "notice"' do
      resource = acl_type.new name: '/tmp/foo', permission: ['o::rwx'], ignore_missing: :notify
      expect(resource[:name]).to eq('/tmp/foo')
      expect(resource[:ignore_missing]).to eq(:notify)
    end

    it 'fails with an invalid default' do
      expect do
        acl_type.new name: '/tmp/foo', permission: ['o::rwx:wrong']
      end.to raise_error(Puppet::ResourceError, %r{First field of 4 must be})
    end

    it 'fails with a wrong action' do
      expect do
        acl_type.new name: '/tmp/foo', permission: ['o::rwx'], action: :xset
      end.to raise_error(Puppet::ResourceError)
    end

    it 'accepts a recurselimit' do
      expect do
        acl_type.new name: '/tmp/foo', permission: ['o::rwx'], recurselimit: 42
      end.to raise_error(Puppet::Error)
    end

    it 'fails with a wrong recurselimit' do
      expect do
        acl_type.new name: '/tmp/foo', permission: ['o::rwx'], recurselimit: :a
      end.to raise_error(Puppet::Error)
    end

    it 'fails with a wrong first argument' do
      expect do
        acl_type.new name: '/tmp/foo', permission: ['wrong::rwx']
      end.to raise_error(Puppet::ResourceError)
    end

    it 'fails with a wrong last argument' do
      expect do
        acl_type.new name: '/tmp/foo', permission: ['user::-_-']
      end.to raise_error(Puppet::ResourceError)
    end

    it 'fails with a wrong ignore_missing' do
      expect do
        acl_type.new name: '/tmp/foo', permission: ['o::rwx'], ignore_missing: :true
      end.to raise_error(Puppet::ResourceError)
    end
  end

  context 'when removing default parameters' do
    basic_perms = ['user:foo:rwx', 'group:foo:rwx']
    advanced_perms = ['user:foo:rwx', 'group:foo:rwx', 'default:user:foo:---']
    advanced_perms_results = ['user:foo:rwx', 'group:foo:rwx']
    mysql_perms = [
      'user:mysql:rwx',
      'd:user:mysql:rw',
      'mask::rwx'
    ]
    mysql_perms_results = [
      'user:mysql:rwx',
      'mask::rwx'
    ]
    it 'does not do anything with no defaults' do
      expect(acl_type.pick_default_perms(basic_perms)).to match_array(basic_perms)
    end

    it 'removes defaults' do
      expect(acl_type.pick_default_perms(advanced_perms)).to match_array(advanced_perms_results)
    end

    it 'removes defaults with d:' do
      expect(acl_type.pick_default_perms(mysql_perms)).to match_array(mysql_perms_results)
    end
  end
end
