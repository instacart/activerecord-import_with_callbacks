class ActiveRecord::Base
  class << self
    def find_associated_objects_for_import(associated_objects_by_class, model)
      associated_objects_by_class[model.class.name] ||= {}
      model.class.reflect_on_all_associations(:has_many).each do |association_reflection|
        associated_objects_by_class[model.class.name][association_reflection.name] ||= []
        association = model.association(association_reflection.name)
        association.loaded!
        changed_objects = association.select { |a| a.new_record? || a.changed? }
        changed_objects.each do |child|
          child.send("#{association_reflection.foreign_key}=", model.id)
        end
        associated_objects_by_class[model.class.name][association_reflection.name].concat changed_objects
      end
      associated_objects_by_class
    end
  end
end
