require 'gravgen'
require 'tempfile'

describe 'Avatar' do
  context 'when instantiated without arguments' do
    before {@avatar = Avatar.new}

    it 'should find uuidgen in path' do
     @avatar.send(:uuidgen_in_path?).should be_true
    end
    
    it 'should use a uuid when no email is provided' do
      @avatar.instance_variable_get(:@email).should_not be_nil
    end

    it 'should create a valid hash from a random uuid' do
      empty_string_hash = 'd41d8cd98f00b204e9800998ecf8427e'
      @avatar.email_hash.should_not == empty_string_hash
      @avatar.email_hash.should have(32).characters
    end
  end # context 'without arguments'
  
  context 'when instantiated with explicit arguments' do
    it 'should create a valid hash from a known uuid' do
      @avatar = Avatar.new :email => '52854ebf-b9ce-44a1-aa97-aca08bb1820b'
      @avatar.email_hash.should == '57b661516282b4020a78391b16dbec56'
    end

    it 'should create a valid hash from an email address' do
      @avatar = Avatar.new :email => 'foo@example.com'
      @avatar.email_hash.should == 'b48def645758b95537d4424c84d1a9ff'
    end

    it 'should not allow invalid avatar types' do
      lambda {
        Avatar.new(:type=>'foo')
      }.should raise_error
    end

    it 'should not allow strings in avatar sizes' do
      lambda {
        Avatar.new(:size=>'foo')
      }.should raise_error(ArgumentError)
    end

    it 'should not allow avatar sizes below the minimum' do
      lambda {
        Avatar.new(:size => Avatar::MIN_SIZE_IN_PX.pred).should raise_error
      }.should raise_error
    end

    it 'should not allow avatar sizes above the maximum' do
      lambda {
        Avatar.new(:size => Avatar::MAX_SIZE_IN_PX.succ).should raise_error
      }.should raise_error
    end
  end # context 'with explicit arguments'

  describe '#fetch' do
    it 'should not fetch the gravatar default image' do
      @avatar = Avatar.new
      Digest::MD5.hexdigest(
        @avatar.fetch
      ).should_not == 'd5fe5cbcc31cff5f8ac010db72eb000c'
    end
  end

  describe '#write' do
    def calc_digest type
      filename = Tempfile.new('avatar-').path
      @avatar = Avatar.new :email => 'foo@example.com', :type => type
      @avatar.fetch
      @avatar.write filename
      digest = Digest::MD5.file(filename).hexdigest
    end

    it 'should create a valid identicon image' do
      calc_digest('identicon').should == '5e0d21a154408b52620eb216b5ece80c'
    end

    it 'should create a valid monsterid image' do
      calc_digest('monsterid').should == 'dff46665c13c893df59961d7250d7be0'
    end

    it 'should create a valid wavatar image' do
      calc_digest('wavatar').should == '812c451340234731b4a6b2514a3d96cd'
    end

    it 'should create a valid retro image' do
      calc_digest('retro').should == 'eebff180322f4538d4525da84ee4e92d'
    end
  end # describe '#write'
end # describe Avatar
