CREATE TYPE "status" AS ENUM (
    'online',
    'offline'
    );

CREATE TYPE "messageType" AS ENUM (
    'text',
    'audio',
    'image',
    'video',
    'file'
    );

CREATE TABLE "company" (
                           "id" bigserial PRIMARY KEY,
                           "name" varchar(100) NOT NULL,
                           "subdomain" varchar(50) UNIQUE NOT NULL,
                           "description" text,
                           "webhook_url" text,
                           "api_key" varchar(64) UNIQUE NOT NULL,
                           "self_register" bool DEFAULT false,
                           "is_active" boolean DEFAULT true,
                           "created_at" timestamp DEFAULT (now()),
                           "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "users" (
                         "id" bigserial PRIMARY KEY,
                         "username" varchar(20),
                         "email" varchar(64),
                         "password_hash" varchar(64) NOT NULL,
                         "avatar_url" text,
                         "phone" varchar(20),
                         "status" status DEFAULT 'offline',
                         "last_seen" timestamp,
                         "company_id" bigint,
                         "created_at" timestamp DEFAULT (now()),
                         "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "chats" (
                         "id" bigserial PRIMARY KEY,
                         "company_id" bigint NOT NULL,
                         "peer_user_1_id" bigint NOT NULL,
                         "peer_user_2_id" bigint NOT NULL,
                         "last_message_id" bigint NOT NULL,
                         "created_at" timestamp DEFAULT (now()),
                         "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "messages" (
                            "id" bigserial PRIMARY KEY,
                            "chat_id" bigint NOT NULL,
                            "user_id" bigint NOT NULL,
                            "content" text,
                            "message_type" "messageType" NOT NULL DEFAULT 'text',
                            "reply_to_id" bigint,
                            "attachments" jsonb DEFAULT '[]',
                            "is_edited" boolean DEFAULT false,
                            "is_deleted" boolean DEFAULT false,
                            "company_id" bigint,
                            "edited_at" timestamp,
                            "deleted_at" timestamp,
                            "created_at" timestamp DEFAULT (now()),
                            "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "attachments" (
                               "id" bigserial PRIMARY KEY,
                               "file_id" uuid UNIQUE NOT NULL,
                               "original_name" varchar(255) NOT NULL,
                               "mime_type" varchar(100) NOT NULL,
                               "file_size" bigint NOT NULL,
                               "uploaded_by" bigint NOT NULL,
                               "company_id" bigint NOT NULL,
                               "chat_id" bigint NOT NULL,
                               "message_id" bigint NOT NULL,
                               "created_at" timestamp DEFAULT (now())
);

CREATE INDEX ON "company" ("subdomain");

CREATE INDEX ON "company" ("api_key");

CREATE UNIQUE INDEX "idx_users_email_workspace_unique" ON "users" ("email", "company_id");

CREATE UNIQUE INDEX "idx_users_username_workspace_unique" ON "users" ("username", "company_id");

CREATE INDEX ON "users" ("status");

CREATE INDEX ON "users" ("last_seen");

ALTER TABLE "users" ADD FOREIGN KEY ("company_id") REFERENCES "company" ("id");

ALTER TABLE "chats" ADD FOREIGN KEY ("company_id") REFERENCES "company" ("id");

ALTER TABLE "chats" ADD FOREIGN KEY ("peer_user_1_id") REFERENCES "users" ("id");

ALTER TABLE "chats" ADD FOREIGN KEY ("peer_user_2_id") REFERENCES "users" ("id");

ALTER TABLE "chats" ADD FOREIGN KEY ("last_message_id") REFERENCES "messages" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("chat_id") REFERENCES "chats" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("reply_to_id") REFERENCES "messages" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("company_id") REFERENCES "company" ("id");

ALTER TABLE "attachments" ADD FOREIGN KEY ("uploaded_by") REFERENCES "users" ("id");

ALTER TABLE "attachments" ADD FOREIGN KEY ("company_id") REFERENCES "company" ("id");

ALTER TABLE "attachments" ADD FOREIGN KEY ("chat_id") REFERENCES "chats" ("id");

ALTER TABLE "attachments" ADD FOREIGN KEY ("message_id") REFERENCES "messages" ("id");