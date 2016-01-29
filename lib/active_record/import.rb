class ActiveRecord::Base
  class << self
    def find_associated_objects_for_import(associated_objects_by_class, model)
      associated_objects_by_class[model.class.name] ||= {}
      association_reflections =
        model.class.reflect_on_all_associations(:has_one) +
        model.class.reflect_on_all_associations(:has_many)
      association_reflections.each do |association_reflection|
        associated_objects_by_class[model.class.name][association_reflection.name] ||= []
        association = model.association(association_reflection.name)
        association.loaded!
        association = Array(association.target)
        changed_objects = association.select { |a| a.new_record? || a.changed? }
        changed_objects.each do |child|
          child.send("#{association_reflection.foreign_key}=", model.id)
          # For polymorphic associations
          association_reflection.type.try do |type|
            child.send("#{type}=", model.name)
          end
        end
        associated_objects_by_class[model.class.name][association_reflection.name].concat changed_objects
      end
      associated_objects_by_class
    end
  end
end
