require 'spec_helper'

provider_class = Puppet::Type.type(:acl).provider(:posixacl)

describe provider_class do

  it 'declares a getfacl command' do
    expect{
      provider_class.command :getfacl
    }.not_to raise_error
  end
  it 'declares a setfacl command' do
    expect{
      provider_class.command :setfacl
    }.not_to raise_error
  end
end
