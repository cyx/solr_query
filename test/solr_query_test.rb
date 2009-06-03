require File.dirname(__FILE__) + '/test_helper'

class SolrQueryTest < Test::Unit::TestCase
  context "given term 'quick brown'" do
    should "be quick brown" do
      result = SolrQuery.create do |q|
        q.term 'quick brown'
      end
      
      assert_equal 'quick brown', result
    end
  end
  
  context "given term ' '" do 
    should "be ''" do
      result = SolrQuery.create { |q| q.term ' ' }
      assert_equal '', result
    end
  end
  
  context "given term '' condition 'category_id', nil" do
    should " be '' " do
      result = SolrQuery.create do |q|
        q.term ''
        q.condition 'category_id', nil
      end
      
      assert_equal '', result
    end
  end
  # GIVEN: 
  #
  # SolrQuery.create do |q|
  #     q.union {
  #       q.condition 'allowed', 'all'
  # 
  #       q.union {
  #         q.condition 'allowed', 'contacts'
  #         q.condition 'poster_contact_ids', 1
  #       }
  #     }
  #   end
  context "given the query above" do 
    should "be allowed:all OR (allowed:contacts OR poster_contact_ids:1)" do
      result = SolrQuery.create do |q|
        q.union {
          q.condition 'allowed', 'all'
  
          q.union {
            q.condition 'allowed', 'contacts'
            q.condition 'poster_contact_ids', 1
          }
        }
      end
      
      assert_equal '( allowed:all OR ( allowed:contacts OR poster_contact_ids:1 ) )', result
    end
  end
  
  context "given condition 'allowed', 'all'" do
      should "be allowed:all" do
        result = SolrQuery.create do |q|
          q.condition 'allowed', 'all'
        end
        assert_equal 'allowed:all', result
      end
    end
    
    context "given condition 'allowed', 'all' then condition 'poster_contact_ids', 1" do
      should "be allowed:all AND poster_contact_ids:1" do
        result = SolrQuery.create do |q|
          q.condition 'allowed', 'all'
          q.condition 'poster_contact_ids', 1
        end
        
        assert_equal 'allowed:all AND poster_contact_ids:1', result
      end
    end
    
  context "given condition 'allowed', 'all' union { condition 'poster_contact_ids', 1 condition 'hoy', 'hey' }" do
    should "be allowed:all AND (poster_contact_ids:1 OR hoy:hey)" do
      result = SolrQuery.create do |q|
        q.condition 'allowed', 'all'
        q.union {
          q.condition 'poster_contact_ids', 1
          q.condition 'hoy', 'hey'
        }
      end
      
      assert_equal 'allowed:all AND ( poster_contact_ids:1 OR hoy:hey )', result
    end
  end

  context "given condition 'allowed', 'all' intersection { condition 'poster_contact_ids', 1 condition 'hoy', 'hey' }" do
    should "be allowed:all AND (poster_contact_ids:1 AND hoy:hey)" do
      result = SolrQuery.create do |q|
        q.condition 'allowed', 'all'
        q.intersection {
          q.condition 'poster_contact_ids', 1
          q.condition 'hoy', 'hey'
        }
      end
      
      assert_equal 'allowed:all AND ( poster_contact_ids:1 AND hoy:hey )', result
    end
  end
  
  #   union {
  #     set :allowed, 'all'
  #   
  #     intersection {
  #       set :allowed, 'contacts'
  #       set :poster_contact_ids, 1
  #     }
  #   
  #     union {
  #       set :allowed, 1
  #       set :allowed, 2
  #     }
  #   }
  #   
  context "given the pseudo code above" do
    should "be (allowed:all OR (allowed:contacts AND poster_contact_ids:1) OR (allowed:1 OR allowed:2)" do
      result = SolrQuery.create do |q|
        q.union {
          q.condition 'allowed', 'all'
          
          q.intersection {
            q.condition 'allowed', 'contacts'
            q.condition 'poster_contact_ids', 1
          }
          
          q.union {
            q.condition 'allowed', 1
            q.condition 'allowed', 2
          }
        }
      end
      
      assert_equal '( allowed:all OR ( allowed:contacts AND poster_contact_ids:1 ) OR ( allowed:1 OR allowed:2 ) )', result
    end
  end
  
  context "given condition 'allowed', 'all' intersection { }" do
    should "be allowed:all" do
      result = SolrQuery.create do |q|
        q.condition 'allowed', 'all'
        q.intersection {
          
        }
      end
      
      assert_equal 'allowed:all', result
    end
  end
end
