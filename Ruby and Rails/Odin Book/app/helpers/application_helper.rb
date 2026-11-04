module ApplicationHelper
  def user_avatar(user, size: 40, css_class: "")
    return image_tag("https://www.gravatar.com/avatar/?d=mp&s=#{size}", width: size, height: size, class: "avatar #{css_class}", style: "width: #{size}px; height: #{size}px; object-fit: cover; border-radius: 50%;") if user.nil?

    if user.avatar.attached?
      image_tag user.avatar, width: size, height: size, class: "avatar #{css_class}", alt: user.full_name, style: "width: #{size}px; height: #{size}px; object-fit: cover; border-radius: 50%;"
    elsif user.avatar_url.present?
      image_tag user.avatar_url, width: size, height: size, class: "avatar #{css_class}", alt: user.full_name, style: "width: #{size}px; height: #{size}px; object-fit: cover; border-radius: 50%;"
    else
      image_tag user.gravatar_url(size: size * 2), width: size, height: size, class: "avatar #{css_class}", alt: user.full_name, style: "width: #{size}px; height: #{size}px; object-fit: cover; border-radius: 50%;"
    end
  end

  def format_time_ago(time)
    "#{time_ago_in_words(time)} ago"
  end
end
