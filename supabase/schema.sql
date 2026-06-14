-- RecycPay - Schema PostgreSQL

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'collecteur' CHECK (role IN ('collecteur', 'trieur', 'livreur')),
  photo_url TEXT,
  unique_id TEXT UNIQUE,
  balance DECIMAL DEFAULT 25000,
  rating DECIMAL DEFAULT 4.5,
  completed_missions INT DEFAULT 0,
  points INT DEFAULT 5,
  collected_types TEXT[] DEFAULT '{}',
  latitude DECIMAL,
  longitude DECIMAL,
  is_online BOOLEAN DEFAULT true,
  referral_code TEXT UNIQUE,
  referred_by TEXT,
  referral_earnings DECIMAL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('deposit', 'withdrawal', 'payment', 'commission', 'bonus')),
  amount DECIMAL NOT NULL,
  commission DECIMAL,
  status TEXT DEFAULT 'completed',
  operator TEXT,
  phone TEXT,
  description TEXT,
  reference TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  image_url TEXT,
  description TEXT NOT NULL,
  waste_types TEXT[] DEFAULT '{}',
  likes INT DEFAULT 0,
  liked_by TEXT[] DEFAULT '{}',
  comments_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_photo_url TEXT,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  phone TEXT,
  email TEXT,
  website TEXT,
  city TEXT NOT NULL,
  address TEXT,
  latitude DECIMAL,
  longitude DECIMAL,
  rating DECIMAL DEFAULT 0,
  opening_hours TEXT,
  logo_url TEXT,
  materials JSONB DEFAULT '[]',
  services TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_created ON posts(created_at DESC);
CREATE INDEX idx_comments_post ON comments(post_id);
CREATE INDEX idx_profiles_role ON profiles(role);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);
