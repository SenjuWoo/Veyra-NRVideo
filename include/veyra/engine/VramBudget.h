// SPDX-License-Identifier: GPL-3.0-only
#pragma once

#include <algorithm>
#include <cstdint>

namespace veyra::engine {

constexpr uint64_t vramMinimumHeadroom(uint64_t budget) {
    // Use the current WDDM budget, which can shrink when other apps use the GPU.
    return std::clamp<uint64_t>(budget / 16, 256ull << 20, 1024ull << 20);
}

constexpr bool vramBudgetTight(uint64_t usage, uint64_t budget) {
    return usage && budget && (usage >= budget || budget - usage < vramMinimumHeadroom(budget));
}

}
