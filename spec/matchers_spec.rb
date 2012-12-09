require 'spec_helper'

describe "Custom rspec matchers" do
  describe :beOrderedHaving do
    context "passing" do
      it { [1,2,3].should beOrderedHaving(1).before(1)  }
      it { [1,2,3].should beOrderedHaving(1).before(2)  }
      it { [1,2,3].should beOrderedHaving(1).before(3)  }

      it { [1,2,3].should beOrderedHaving(1).before(2,3)  }
      it { [1,2,3].should beOrderedHaving(2).before(3)  }

      it { [1,2,3].should beOrderedHaving(1,2).before(3)  }
      it { [1,2,3].should beOrderedHaving(2,1).before(3)  }
    end

    context "failing" do
      it { [1,2,3].should_not beOrderedHaving(2).before(1)  }
      it { [1,2,3].should_not beOrderedHaving(3).before(1)  }
      it { [1,2,3].should_not beOrderedHaving(2,3).before(1)  }

      it { [1,2,3].should_not beOrderedHaving(3).before(2)  }
      it { [1,2,3].should_not beOrderedHaving(1,3).before(2)  }

      it { [1,2,3].should_not beOrderedHaving(3).before(1,2)  }
      it { [1,2,3].should_not beOrderedHaving(2).before(3,1)  }

      it { [1,2,3].should_not beOrderedHaving(42).before(3)  }
      it { [1,2,3].should_not beOrderedHaving(1).before(42)  }
    end
  end
end
