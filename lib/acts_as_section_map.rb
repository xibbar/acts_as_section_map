module XibbarNet
  module Acts #:nodoc:
    module SectionMap #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)              
      end
      module ClassMethods
        def acts_as_section_map(options = {})
          include InstanceMethods
          if column_names.include?("depth")
            alias max_depth max_depth_with_depth_column
            protected
            define_method :move_to do |*args| #:nodoc:
              super(args[0],args[1],args[2])
              update_attribute(:depth,level)
            end
          else
            alias max_depth max_depth_without_depth_column
          end
        end
        def set_depth
          find(:all).each{|s|s.update_attribute(:depth,s.level)}
        end
        def max_depth_with_depth_column
          maximum(:depth) || 0
        end
        def max_depth_without_depth_column
          find(:all).map(&:level).sort.last
        end
        def leaves
          # 葉の全て
          find(:all).select{|section|
            section.children_count==0
          }.sort{|a,b|
            a<=>b
          }
        end
        def table
          # 配列の配列にしたもの
          leaves.map{|leaf|
            leaf.self_and_ancestors
          }
        end
        def table2
          # tableだとeachで回すときに使いづらいので加工したもの
          last_line=[]
          table2=[]
          table.map{|line|
            table2.push line-last_line
            last_line=line
          }
          table2
        end
        module InstanceMethods
          def left?
            if parent_id
              self.self_and_siblings.first==self
            else
              roots.first==self
            end
          end
          def right?
            if parent_id
              self.self_and_siblings.last==self
            else
              roots.last==self
            end

          end
          def move_to_last_child_of(node)
            if node.children_count>0
              self.move_to_right_of(node.children.last)
            else
              section.move_to_child_of(node)
            end
          end
          def up
            if parent_id
              arr=self_and_siblings
            else
              arr=roots
            end
            mv_num=arr.index(self)-1
            if mv_num>=0
              move_to_left_of(arr[mv_num])
            else
              return nil
            end
          end
          def down
            if parent_id
              arr=self_and_siblings
            else
              arr=roots
            end
            mv_num=arr.index(self)+1
            if mv_num < arr.size 
              move_to_right_of(arr[mv_num])
            else
              return nil
            end
          end
          def leaves
            # 葉
            self.all_children.select{|section|
              section.children_count==0
            }
          end
          def colspan
            children_count>0 ? 1 : self.class.max_depth-self.level+1
          end
          def rowspan
            leaves_count>1 ? leaves_count : 1
          end
        end
      end
    end
  end
end



