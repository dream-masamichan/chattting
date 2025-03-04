class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User

  # Devise モジュール
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # ユーザーの状態
  enum availability: { online: 0, offline: 1, busy: 2 }

  # バリデーション
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :uid, presence: true, uniqueness: { scope: :provider }

  # リレーション
  has_many :account_users, dependent: :destroy_async
  has_many :accounts, through: :account_users
  accepts_nested_attributes_for :account_users

  has_many :inbox_members, dependent: :destroy_async
  has_many :inboxes, through: :inbox_members
  has_many :messages, as: :sender, dependent: :nullify

  has_many :notifications, dependent: :destroy_async
  has_many :notification_subscriptions, dependent: :destroy_async

  has_many :articles, foreign_key: 'author_id', dependent: :nullify, inverse_of: :author

  # コールバック
  before_validation :set_uid, on: :create
  before_validation :normalize_email

  # メール送信
  def send_devise_notification(notification, *args)
    devise_mailer.with(account: Current.account).send(notification, self, *args).deliver_later
  end

  # OAuth ログイン時にユーザーを検索または作成
  def self.from_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.email = auth.info.email if user.email.blank?
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    user.save
    user
  end

  private

  # `uid` を email に基づいて設定（OAuth の場合は `auth.uid` を利用）
  def set_uid
    self.uid ||= email
  end

  # メールアドレスを小文字化
  def normalize_email
    self.email = email.downcase if email.present?
  end
end
