require 'spec_helper'
require 'language_pack/helpers/soldsie_s3_helper'
require 'base64'

describe 'Soldsie S3 Helper' do

  let(:bigquery_local_key_file) { '/tmp/soldsie-event-tracking.p12' }  

  before(:each) do    
    expect(ENV).to receive(:[]).with('AWS_ACCESS_KEY_ID').and_return(Base64.decode64('QUtJQUkzTU1UQVA2Q0c1SE9OT1E=\n'))
    expect(ENV).to receive(:[]).with('AWS_SECRET_ACCESS_KEY').and_return(Base64.decode64('Q3VnSWhxVWNzSnFoQmkyWFhLUVJlMTVUYjBXemNuQUNqaTJDZXZCVg==\n'))
    expect(ENV).to receive(:[]).with('BIGQUERY_KEY_S3_BUCKET').and_return('soldsie-staging-keys')
    expect(ENV).to receive(:[]).with('BIGQUERY_KEY_S3_PATH').and_return('bigquery/Soldsie-event-tracking-staging.p12')
    expect(ENV).to receive(:[]).with('BIGQUERY_KEY_FILENAME').and_return('soldsie-event-tracking.p12')

    allow(ENV).to receive(:[]).with('http_proxy').and_call_original
    allow(ENV).to receive(:[]).with('HTTP_PROXY').and_call_original
    allow_any_instance_of(LanguagePack::Helpers::SoldsieS3Helper).to receive(:build_path).and_return('/tmp')
  end

  after(:each) do
    File.delete(bigquery_local_key_file)
  end
  
  it 'download should be successful for staging files' do
    stub_const('LanguagePack::Helpers::SoldsieS3Helper::S3_FILES', [
      {
        description: 'BigQuery p12 key',
        bucket: ENV['BIGQUERY_KEY_S3_BUCKET'],
        path: ENV['BIGQUERY_KEY_S3_PATH'],
        local_file: ENV['BIGQUERY_KEY_FILENAME']
      }
    ])

    LanguagePack::Helpers::SoldsieS3Helper.new.download
    expect(File.exists?(bigquery_local_key_file)).to be true
    expect(File.zero?(bigquery_local_key_file)).to be false

  end

end