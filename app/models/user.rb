class User < ActiveRecord::Base
  attr_accessible  :is_login, :name, :online_minutes, :password_confirmation, :password
  has_secure_password
  validates_presence_of :name, :password
  validates :name, uniqueness: true
  before_create :generate_token

  def generate_token
    begin
      self[:auth_token] = SecureRandom.urlsafe_base64
    end while User.exists?(auth_token: self[:auth_token])
  end
end
