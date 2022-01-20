# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'posix_acl' do
  context 'with default behaviour' do
    let(:pp) do
      'include posix_acl::requirements'
    end

    it 'works idempotently with no errors' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('acl') do
      it { is_expected.to be_installed }
    end
  end
end
