/*
  Warnings:

  - You are about to drop the column `deadLine` on the `Goal` table. All the data in the column will be lost.
  - Added the required column `deadline` to the `Goal` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Goal" DROP COLUMN "deadLine",
ADD COLUMN     "deadline" TIMESTAMP(3) NOT NULL;
