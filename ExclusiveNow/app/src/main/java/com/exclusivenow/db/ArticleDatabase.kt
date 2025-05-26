package com.exclusivenow.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.exclusivenow.model.SavedArticle

@Database(entities = [SavedArticle::class], version = 2, exportSchema = true)
abstract class ArticleDatabase : RoomDatabase() {

    abstract fun articleDao(): ArticleDao

    companion object {
        @Volatile
        private var INSTANCE: ArticleDatabase? = null

        fun getDatabase(context: Context): ArticleDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    ArticleDatabase::class.java,
                    "article_database"
                ).addMigrations(MIGRATION_1_2)
                    .build()
                INSTANCE = instance
                instance
            }
        }

        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("DROP TABLE IF EXISTS saved_articles")
                database.execSQL("""
                     CREATE TABLE saved_articles (
                         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                         sourceId TEXT,
                         sourceName TEXT,
                         author TEXT,
                         title TEXT,
                         description TEXT,
                         url TEXT,
                         urlToImage TEXT,
                         publishedAt TEXT,
                         content TEXT,
                         savedAt INTEGER NOT NULL DEFAULT 0
                     )
                 """.trimIndent())
            }
        }
    }
}