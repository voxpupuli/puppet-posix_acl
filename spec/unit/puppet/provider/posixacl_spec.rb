require 'spec_helper'
require 'rspec/mocks'

provider_class = Puppet::Type.type(:posix_acl).provider(:posixacl)

describe provider_class do
  it 'declares a getfacl command' do
    expect do
      provider_class.command :getfacl
    end.not_to raise_error
  end
  it 'declares a setfacl command' do
    expect do
      provider_class.command :setfacl
    end.not_to raise_error
  end
  it 'encodes spaces in group names' do
    RSpec::Mocks.with_temporary_scope do
      Puppet::Type.stubs(:getfacl).returns("group:test group:rwx\n")
      File.stubs(:exist?).returns(true)
      expect do
        provider_class.command :permission
      end == ['group:test\040group:rwx']
    end
  end
end
