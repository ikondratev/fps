ThinkingSphinx::Index.define :question, with: :active_record do
  indexes title, sortable: true
  indexes body
  indexes user.email

  # attributes
  has user_id, created_at, updated_at
end
