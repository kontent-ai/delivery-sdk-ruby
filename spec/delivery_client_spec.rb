RSpec.describe Delivery::DeliveryClient do
  before(:all) do
    @dc = Delivery::DeliveryClient.new('2695019d-6404-00c1-fea5-e0f187569329')
  end

  describe '.items' do
    context 'given no parameters' do
      it 'gets 30 items' do
        expect(@dc.items.items.length).to eq(30)
      end
    end
    context 'given AllFilter for personas [coffee_lover coffee_blogger]' do
      it 'gets 2 items' do
        f = Delivery::Filters::AllFilter.new('elements.personas', %w[coffee_lover coffee_blogger])
        expect(@dc.items(f).items.length).to eq(2)
      end
    end
    context 'given AnyFilter for personas [coffee_lover coffee_blogger]' do
      it 'gets 5 items' do
        f = Delivery::Filters::AnyFilter.new('elements.personas', %w[coffee_lover coffee_blogger])
        expect(@dc.items(f).items.length).to eq(5)
      end
    end
    context 'given ContainsFilter for personas coffee_lover' do
      it 'gets 3 items' do
        f = Delivery::Filters::ContainsFilter.new('elements.personas', 'coffee_lover')
        expect(@dc.items(f).items.length).to eq(3)
      end
    end
    context 'given EqualsFilter for system.codename' do
      it 'gets one item' do
        f = Delivery::Filters::EqualsFilter.new('system.codename', 'aeropress')
        expect(@dc.items(f).items.length).to eq(1)
      end
    end
    context 'given GreaterThanFilter for elements.price 30' do
      it 'gets one item' do
        f = Delivery::Filters::GreaterThanFilter.new('elements.price', 30)
        expect(@dc.items(f).items.length).to eq(1)
      end
    end
  end

  describe '.item' do
    context 'given a code name' do
      it 'gets one item' do
        expect(@dc.item('aeropress').item).to be_a Delivery::ContentItem
      end
    end
  end
end
