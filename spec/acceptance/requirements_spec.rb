# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'posix_acl' do
  context 'with default behaviour' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        'include posix_acl::requirements'
      end
    end

    describe package('acl') do
      it { is_expected.to be_installed }
    end
  end
end
