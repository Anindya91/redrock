class Omega::Customer < Omega
  attr_accessor :id, :first_name, :middle_name, :last_name, :email_address

  has_many :phone_numbers, class_name: "Omega::PhoneNumber"

  after_initialize :set_phone_numbers

  private

  def set_phone_numbers
    self.phone_numbers = OmegaClient.new.get_phone_numbers(self.id)
  end
end
