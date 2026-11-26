// SPDX-License-Identifier: GPL-3.0-only
#pragma once
#include <chrono>
#include <cstdint>
#include <mutex>
#include <optional>

namespace veyra::xbox {

// Largest interval between consecutive video access units and how many intervals exceed a late
// threshold, collected until the reader closes the window. observe() runs on the network thread,
// takeWindow() on the stats thread.
class ArrivalGapTracker {
public:
    using Clock = std::chrono::steady_clock;
    struct Window {
        double maxGapMs = 0;
        uint64_t lateUnits = 0;
    };

    explicit ArrivalGapTracker(Clock::duration lateAfter = std::chrono::milliseconds(25)) : lateAfter_(lateAfter) {}

    void observe(Clock::time_point arrival) {
        std::lock_guard lock(mutex_);
        if (last_) {
            const Clock::duration gap = arrival - *last_;
            if (gap > maxGap_) maxGap_ = gap;
            if (gap > lateAfter_) ++late_;
        }
        last_ = arrival;
    }

    // The last arrival survives the reset: a stall that spans a window boundary is reported in the
    // window where the stream resumes instead of disappearing.
    Window takeWindow() {
        std::lock_guard lock(mutex_);
        const Window w{std::chrono::duration<double, std::milli>(maxGap_).count(), late_};
        maxGap_ = Clock::duration::zero();
        late_ = 0;
        return w;
    }

private:
    std::mutex mutex_;
    const Clock::duration lateAfter_;
    std::optional<Clock::time_point> last_;
    Clock::duration maxGap_ = Clock::duration::zero();
    uint64_t late_ = 0;
};

} // namespace veyra::xbox
