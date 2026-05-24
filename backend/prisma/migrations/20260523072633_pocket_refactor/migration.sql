/*
  Warnings:

  - You are about to drop the column `categoryId` on the `Transaction` table. All the data in the column will be lost.
  - You are about to alter the column `amount` on the `Transaction` table. The data in that column could be lost. The data in that column will be cast from `DoublePrecision` to `Integer`.
  - You are about to drop the `Budget` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Category` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Goal` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `pocketId` to the `Transaction` table without a default value. This is not possible if the table is not empty.
  - Added the required column `pocketNameShot` to the `Transaction` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "PocketType" AS ENUM ('Main', 'Spending', 'Goal');

-- CreateEnum
CREATE TYPE "TransactionStatus" AS ENUM ('Active', 'Voided', 'VoidEntry');

-- DropForeignKey
ALTER TABLE "Budget" DROP CONSTRAINT "Budget_categoryId_fkey";

-- DropForeignKey
ALTER TABLE "Budget" DROP CONSTRAINT "Budget_userId_fkey";

-- DropForeignKey
ALTER TABLE "Category" DROP CONSTRAINT "Category_userId_fkey";

-- DropForeignKey
ALTER TABLE "Goal" DROP CONSTRAINT "Goal_userId_fkey";

-- DropForeignKey
ALTER TABLE "Transaction" DROP CONSTRAINT "Transaction_categoryId_fkey";

-- AlterTable
ALTER TABLE "Transaction" DROP COLUMN "categoryId",
ADD COLUMN     "incomeSource" TEXT,
ADD COLUMN     "incomeSourceNote" TEXT,
ADD COLUMN     "isTransfer" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "pocketId" INTEGER NOT NULL,
ADD COLUMN     "pocketNameShot" TEXT NOT NULL,
ADD COLUMN     "status" "TransactionStatus" NOT NULL DEFAULT 'Active',
ADD COLUMN     "transferPairId" INTEGER,
ADD COLUMN     "voidRefId" INTEGER,
ALTER COLUMN "amount" SET DATA TYPE INTEGER;

-- DropTable
DROP TABLE "Budget";

-- DropTable
DROP TABLE "Category";

-- DropTable
DROP TABLE "Goal";

-- CreateTable
CREATE TABLE "Pocket" (
    "id" SERIAL NOT NULL,
    "pocketName" TEXT NOT NULL,
    "balance" INTEGER NOT NULL DEFAULT 0,
    "pocketType" "PocketType" NOT NULL DEFAULT 'Spending',
    "targetAmount" INTEGER,
    "deadline" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),
    "userId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Pocket_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Pocket_userId_idx" ON "Pocket"("userId");

-- CreateIndex
CREATE INDEX "Transaction_userId_idx" ON "Transaction"("userId");

-- CreateIndex
CREATE INDEX "Transaction_pocketId_idx" ON "Transaction"("pocketId");

-- AddForeignKey
ALTER TABLE "Pocket" ADD CONSTRAINT "Pocket_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_pocketId_fkey" FOREIGN KEY ("pocketId") REFERENCES "Pocket"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
