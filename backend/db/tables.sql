BEGIN;

CREATE SCHEMA IF NOT EXISTS nestegg;

-- wallets
CREATE TABLE nestegg.wallets (
  wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE DEFAULT auth.uid()
    REFERENCES auth.users(id) ON DELETE CASCADE,
  current_resources NUMERIC(14,2) NOT NULL DEFAULT 0
    CHECK (current_resources >= 0),
  savings NUMERIC(14,2) NOT NULL DEFAULT 0
    CHECK (savings >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- categories
CREATE TABLE nestegg.deposit_categories (
  category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_name TEXT NOT NULL UNIQUE
    CHECK (length(trim(category_name)) > 0)
);

CREATE TABLE nestegg.withdrawal_categories (
  category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_name TEXT NOT NULL UNIQUE
    CHECK (length(trim(category_name)) > 0)
);

-- deposits and withdrawals
CREATE TABLE nestegg.deposits (
  deposit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL
    REFERENCES nestegg.wallets(wallet_id) ON DELETE CASCADE,
  category_id UUID NOT NULL
    REFERENCES nestegg.deposit_categories(category_id) ON DELETE RESTRICT,
  deposit_value NUMERIC(14,2) NOT NULL
    CHECK (deposit_value > 0),
  deposited_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE nestegg.withdrawals (
  withdrawal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL
    REFERENCES nestegg.wallets(wallet_id) ON DELETE CASCADE,
  category_id UUID NOT NULL
    REFERENCES nestegg.withdrawal_categories(category_id) ON DELETE RESTRICT,
  withdrawal_value NUMERIC(14,2) NOT NULL
    CHECK (withdrawal_value > 0),
  additional_desc TEXT,
  withdrawn_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE nestegg.relocations (
  relocation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL
    REFERENCES nestegg.wallets(wallet_id) ON DELETE CASCADE,
  direction TEXT NOT NULL
    CHECK (direction IN ('saving_to_main', 'main_to_saving')),
  relocation_value NUMERIC(14,2) NOT NULL
    CHECK (relocation_value > 0),
  relocated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- shares
CREATE TABLE nestegg.owned_shares (
  owned_share_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL
    REFERENCES nestegg.wallets(wallet_id) ON DELETE CASCADE,
  share_shortname TEXT NOT NULL
    CHECK (length(trim(share_shortname)) > 0),
  share_fullname TEXT NOT NULL
    CHECK (length(trim(share_fullname)) > 0),
  amount NUMERIC(20,8) NOT NULL DEFAULT 0
    CHECK (amount >= 0),
  UNIQUE (wallet_id, share_shortname)
);

-- indexes
CREATE INDEX deposits_wallet_date_idx
  ON nestegg.deposits (wallet_id, deposited_at DESC);

CREATE INDEX deposits_category_idx
  ON nestegg.deposits (category_id);

CREATE INDEX withdrawals_wallet_date_idx
  ON nestegg.withdrawals (wallet_id, withdrawn_at DESC);

CREATE INDEX withdrawals_category_idx
  ON nestegg.withdrawals (category_id);

CREATE INDEX relocations_wallet_date_idx
  ON nestegg.relocations (wallet_id, relocated_at DESC);



ALTER TABLE nestegg.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE nestegg.deposit_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE nestegg.withdrawal_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE nestegg.deposits ENABLE ROW LEVEL SECURITY;
ALTER TABLE nestegg.withdrawals ENABLE ROW LEVEL SECURITY;
ALTER TABLE nestegg.relocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE nestegg.owned_shares ENABLE ROW LEVEL SECURITY;

COMMIT;