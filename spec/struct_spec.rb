require_relative '../struct'

RSpec.describe MyStruct do

  before :each do
    @Foo = MyStruct.new(:one, :two)
    @bar = @Foo.new('a', 'b')
    @baz = @Foo.new('c', 'd')
  end

  %i[ == [] []= dig each each_pair eql? hash inspect length members select
      size to_a to_h to_s values values_at ].each do |method|
    it "should respond to #{method}" do
      expect(@bar).to respond_to(method)
    end
  end

  it 'should properly create instances if first arg is String' do
    MyStruct.new('Foo', :bar)
    MyStruct::Foo.new('baz')
    expect { MyStruct.new('a', :b) }.to raise_error(NameError)
  end

  it 'should handle arity mismatch' do
    expect { @Foo.new('a') }.to raise_error(ArgumentError)
  end

  it 'should properly determine equality' do
    expect(@bar == @baz).to be_falsey
    expect(@bar == @Foo.new('a','b')).to be_truthy
    expect(@bar == 'sample').to be_falsey
  end

  it 'should properly react to indexing' do
    expect(@bar[0]).to be == 'a'
    expect(@bar[1]).to be == 'b'
    expect(@bar[2]).to be_nil
    expect(@bar[-1]).to be == 'b'
    expect(@bar[:one]).to be == 'a'
    expect(@bar['one']).to be == 'a'
  end

  it 'should properly react to index assignment' do
    expect { @bar[0] = 'z' }.to change(@bar, :one)
  end

  it 'should properly react to dig' do
    # following lines snatched from Struct doc page

    Goo = MyStruct.new(:a)
    f = Goo.new(Goo.new({b: [1, 2, 3]}))

    expect(f.dig(:a, :a, :b, 0)).to be == 1
    expect(f.dig(:b, 0)).to be_nil
    expect { f.dig(:a, :a, :b, :c) }.to raise_error(TypeError)
  end

  it 'should properly react to each and each_pair' do
    @bar.each { |k| expect(%w[a b]).to include(k) }
    pairs = [[:one, 'a'], [:two, 'b']]
    @bar.each_pair { |k, v| expect(pairs).to include([k, v]) }
  end

  it 'should properly react to eql?' do
    expect(@bar.eql? @baz).to be_truthy
  end

  it 'should properly react to hash' do
    expect(@bar.hash == @bar.to_h.hash).to be_truthy
  end

  it 'should properly determine length' do
    expect(@bar.length).to be == 2
    expect(@bar.size).to be == 2
  end

  it 'should properly return members' do
    expect(@bar.members).to be == %i[one two]
  end

  it 'should properly return select' do
    expect(@bar.select { |e| e == 'a' }).to be == ['a']
  end

  it 'should properly convert itself to hash and array' do
    expect(@bar.to_h).to be == { one: 'a', two: 'b' }
    expect(@bar.to_a).to be == %w[a b]
  end

  it 'should properly return values' do
    Customer = Struct.new(:name, :address, :zip)
    joe = Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345)
    expect(joe.to_a[1]).to be == '123 Maple, Anytown NC'
  end

  it 'also should return proper values at' do
    C = Struct.new(:name, :address, :zip)
    joe = C.new('Joe Smith', '123 Maple, Anytown NC', 12_345)
    expect(joe.values_at(0, 2)).to be == ['Joe Smith', 12_345]
  end

  it 'should properly process blocks' do
    Q = MyStruct.new(:a) do
      def k
        @a
      end

      def p
        42
      end
    end
    q = Q.new('a')
    expect(q.k).to be == 'a'
    expect(q.p).to be == 42
  end
end
